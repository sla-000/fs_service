<p float="left">
  <a href="https://github.com/sla-000/fs_service/actions"><img src="https://github.com/sla-000/fs_service/actions/workflows/on-merge.yaml/badge.svg" alt="Last main analysis and tests status"></a>
  <a href="https://coveralls.io/github/sla-000/fs_service"><img src="https://coveralls.io/repos/github/sla-000/fs_service/badge.svg" alt="Coverage Status"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="MIT License"/></a>
</p>

# fs_service

`fs_service` is a Dart command-line utility for importing, exporting, and managing data in Cloud Firestore using a Google Service Account.

## Features

- **Recursive Operations**: Export or import Firestore documents and collections while preserving all nested subcollections and documents.
- **Type Preservation**: Full support for standard JSON data types as well as native Firestore data types (Timestamps, GeoPoints, Document References, and Bytes/Blobs).
- **Flexible IO**: Read from and write to standard output / standard input (STDOUT / STDIN) or specify JSON files.
- **Metadata Customization**: Configurable metadata and value prefixes to prevent field name collisions.
- **Piping & Copying**: Easily copy documents or collections within or across projects using standard Unix pipelines.

---

## Installation & Setup

Add `fs_service` to your `pubspec.yaml`:

```yaml
dev_dependencies:
  fs_service:
    git:
      url: https://github.com/sla-000/fs_service.git
      ref: dev
```

Or install it directly via Dart pub:

```bash
dart pub add dev:fs_service
```

---

## Authentication

`fs_service` uses a Firestore Service Account for authentication:

1. Create a Service Account in your Firebase / Google Cloud console for your project.
2. Download the JSON credentials file.
3. Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-credentials.json"
```

For more details, see [Google Cloud Application Default Credentials](https://cloud.google.com/docs/authentication/application-default-credentials#GAC).

---

## Database & Path Structure

Firestore organizes data in alternating collections and documents:
- A document path starts with a collection: `collection1/document1`
- A collection path can be a root collection (`collection1`) or a subcollection (`collection1/document1/collection2`)

The absolute path in Firestore is structured as:
```text
projects/{projectId}/databases/{databaseId}/documents
```

Pass the required `--project` (`-p`) option and optionally `--database` (defaults to `(default)`).

---

## Available Commands

| Command | Description | Path Example |
| :--- | :--- | :--- |
| `get-doc` | Get a document and all its nested subcollections recursively to JSON (STDOUT or file). | `col1/doc1` |
| `get-col` | Get a collection and all its nested documents recursively to JSON (STDOUT or file). | `col1` or `col1/doc1/col2` |
| `add-doc` | Import/add a document and all nested structures into a collection from JSON (STDIN or file). | `col1` or `col1/doc1/col2` |
| `add-col` | Import/add a collection and all nested structures into a document from JSON (STDIN or file). | `col1/doc1` |
| `del-doc` | Recursively delete a document and all its nested collections and documents. | `col1/doc1` |
| `del-col` | Recursively delete a collection and all its nested documents and collections. | `col1` or `col1/doc1/col2` |

---

## Command Options

### General Settings

- `-p, --project <myProject>` (**Required**): Name of your Firebase project ID.
- `--database <myDatabase>`: Name of the Firestore database (defaults to `(default)`).

### Input / Output Settings

- `-o, --out-file <path.json>`: Output file path for `get-doc` and `get-col`. If omitted, output is printed to `STDOUT`.
- `-i, --in-file <path.json>`: Input file path for `add-doc` and `add-col`. If omitted, input is read from `STDIN`.

### Root Name Override Settings

- `-c, --change-name <newName>`: Change the root document or collection name when uploading via `add-doc` or `add-col`.

### Metadata & Value Prefix Settings

- `--meta-prefix <prefix>` (default: `$`): Prefix for metadata fields (e.g. `$name`, `$collections`, `$documents`, `$createTime`, `$updateTime`). Change if your Firestore field names conflict with default metadata keys.
- `--reference-prefix <prefix>` (default: `reference://`): Prefix for serializing/deserializing Firestore Document References.
- `--location-prefix <prefix>` (default: `location://`): Prefix for serializing/deserializing Firestore GeoPoints.
- `--bytes-prefix <prefix>` (default: `bytes://`): Prefix for serializing/deserializing Firestore Bytes/Blobs.
- `--datetime-prefix <prefix>` (default: `datetime://`): Prefix for serializing/deserializing Firestore Timestamps.

### Other Settings

- `--subcollections` (default: `true`): Include nested subcollections and documents recursively for `get-doc` and `get-col`. Pass `--no-subcollections` to disable fetching subcollections.

### Logging Settings

- `-v, --verbose <level>`: Set logging verbosity. Messages are printed to `STDERR`.
  - `info`: Print detailed process info.
  - `trace`: Trace all activity.

---

## Data Types & JSON Serialization Format

`fs_service` handles standard JSON data types directly (strings, numbers, booleans, null, maps, lists). Special Firestore data types are encoded using prefixed strings:

| Firestore Type | JSON Format Example |
| :--- | :--- |
| **Timestamp** | `"datetime://2023-10-21T11:26:40.152Z"` (UTC format) |
| **GeoPoint** | `"location://34.3456/-23.432"` (`location://latitude/longitude`) |
| **Document Reference** | `"reference://projects/myProject/databases/(default)/documents/col1/doc1"` |
| **Bytes (Blob)** | `"bytes://SGVsbG8gV29ybGQ="` (Base64 encoded string) |

### Metadata Fields

Metadata fields assist in preserving and restoring database structure:

- `$name`: Name / ID of the document or collection.
- `$createTime`: Document creation timestamp (ISO 8601, read-only).
- `$updateTime`: Document update timestamp (ISO 8601, read-only).
- `$collections`: Array of nested child collection objects inside a document.
- `$documents`: Array of nested child document objects inside a collection.

> **Note**: `$createTime` and `$updateTime` fields are ignored when importing data via `add-doc` or `add-col`, as Firestore manages these timestamps automatically.

---

## Usage Examples

### 1. Exporting Data

Export a single document and all its subcollections to a JSON file:
```bash
dart run fs_service get-doc col1/doc1 --project=myProject --out-file=doc1.json
```

Export an entire collection to STDOUT:
```bash
dart run fs_service get-col col1 --project=myProject
```

### 2. Importing Data

Import a document JSON into a collection:
```bash
dart run fs_service add-doc col1 --project=myProject --in-file=doc1.json
```

Import a document with a new ID using the `-c` option:
```bash
dart run fs_service add-doc col1 -c newDocId --project=myProject --in-file=doc1.json
```

### 3. Piping Across Projects or Collections

Copy a document directly from one collection to another using Unix pipes:
```bash
dart run fs_service get-doc col1/doc1 --project=sourceProject | \
  dart run fs_service add-doc col2 -c doc1_copy --project=targetProject
```

### 4. Deleting Data

Recursively delete a document and all nested collections:
```bash
dart run fs_service del-doc col1/doc1 --project=myProject
```

Recursively delete a collection:
```bash
dart run fs_service del-col col1 --project=myProject
```

---

## Detailed Help

To display comprehensive CLI help and full list of options, run:

```bash
dart run fs_service --help
```

To view help for a specific command:

```bash
dart run fs_service help get-doc
```
