# The purpose of the fs_service utility

The utility is designed to work with data in Firestore.

The tool can:
- Import Firestore documents and collections and print them to a console or write to JSON files.
- Export documents and collections from a console or JSON files to Firestore.
- Delete Firestore documents and collections.
- Perform all these operations recursively, preserving the internal structure of Firestore and all 
  data types that exist in Firestore.


# Add tool to your project

Add this line manually to your dev_dependencies:
```yaml
dev_dependencies:
  fs_service: ^1.0.0
```
or alternatively run this command in the root folder of your app, where the pubspec.yaml file is located:
```bash
dart pub add dev:fs_service
```


# Getting access to Firestore project

⚠️ To access the data, a Firestore service account is used. What is needed for work:
- Create a service account for your Firestore project.
- Download JSON with credentials to access the account.
- Set the GOOGLE_APPLICATION_CREDENTIALS environment variable and specify the path to the credentials file in it.

For example: 
```bash
export GOOGLE_APPLICATION_CREDENTIALS=secret/myProject-firebase-adminsdk-asda-23423hgh32.json
```

You can read more about this here: https://cloud.google.com/docs/authentication/application-default-credentials#GAC


# General structure of documents and collections in the Firebase

ℹ️ It’s important to understand that the structure has the following form:

- Documents are located at the root of the project.
- A document consists of fields with different types of data.
- Each document can have a nested collection, and not just one.
- Several documents can be nested in each collection. 

⚠️ From this, the following important conclusions are drawn:

- If `colX` is the name of a collection and `docX` is the name of a document, 
    then the relative path from the root of the project will look something like this: `col1/doc1/col2/doc2`, 
    i.e., the path starts with a collection and alternately contains a document and a collection nested in the document.
- You can only add a document to a collection, and a collection only to a document.
- If you delete the collection `col1`, then you delete all documents and collections down this path.
- If you delete the document `doc1`, then you delete all collections and documents down this path.

The absolute path of the root of the project looks like this:

```
projects/{projectId}/databases/{databaseId}/documents
```

You have to pass the projectId value and optionally the databaseId value as the arguments to the application, see examples below.

# get-doc Command

Here is an example of a document `lUAEoKptpXKT1CshnZKX` which contains all types of fields provided by Firestore. 
There is also one nested collection with one document `lUAEoKptpXKT1CshnZKX/col1/lUAEoKptpXKT1CshnZKX` - a copy of the first one.

```bash
dart run fs_service get-doc test/lUAEoKptpXKT1CshnZKX --project=myProject
```

Since the output file is not specified in the options, the result will be printed to STDOUT as follows:

```json

{
  "numberF": 1234.5432,
  "null1": null,
  "ref": "reference://projects/myProject/databases/(default)/documents/en/YLTunxHK6rgPTWHxjJYe",
  "timestamp": "datetime://2023-10-21T11:26:40.152Z",
  "translit": "",
  "geopoint": "location://34.3456/-23.432",
  "word": "four",
  "map": {
    "key1": {
      "key2": "value2"
    }
  },
  "transcript": "fɔːr",
  "boolean": true,
  "number": 12345,
  "array": [
    "array1",
    "array2"
  ],
  "id": "95il61U47MVonL027u3V",
  "$name": "lUAEoKptpXKT1CshnZKX",
  "$createTime": "2023-10-26T12:52:01.608133Z",
  "$updateTime": "2023-10-26T12:52:01.608133Z",
  "$collections": [
    {
      "$name": "col1",
      "$documents": [
        {
          "map": {
            "key1": {
              "key2": "value2"
            }
          },
          "number": 12345,
          "transcript": "fɔːr",
          "word": "four",
          "ref": "reference://projects/myProject/databases/(default)/documents/en/YLTunxHK6rgPTWHxjJYe",
          "numberF": 1234.5432,
          "id": "95il61U47MVonL027u3V",
          "translit": "",
          "geopoint": "location://34.3456/-23.432",
          "boolean": true,
          "array": [
            "array1",
            "array2"
          ],
          "null1": null,
          "timestamp": "datetime://2023-10-21T11:26:40.152Z",
          "$name": "lUAEoKptpXKT1CshnZKX",
          "$createTime": "2024-01-02T11:40:47.284577Z",
          "$updateTime": "2024-01-02T11:40:47.284577Z"
        }
      ]
    }
  ]
}
```

More sophisticated examples are in the [doc-2.json](test/jsons/doc-2.json) and [col-2.json](test/jsons/col-2.json) files.

Time will always be converted to UTC to avoid confusion. 
The default geolocation is stored in the form of `location://{LATITUDE}/{LONGITUDE}`

By default the fields starting with `$` are the meta-data fields. These fields are used to restore 
structure of the Firestore database.

In case the field names of your your database are clash with meta-data field names you can change meta-prefix.
Run the following command to read more about it:
```bash
dart run fs_service help get-doc
```

If you are not happy with `reference://` and other such prefixes you can also change them with the tool options.


# add-doc Command

If you use the `get-doc` command from the example above and use the `add-doc` command through the `|` operator, 
then the result of the `get-doc` command will be passed to the `add-doc` command.

```bash
dart run fs_service get-doc test/lUAEoKptpXKT1CshnZKX --project=myProject | \
  dart run fs_service add-doc test -c doc4 --project=ella500
```

In this case, the document `test/lUAEoKptpXKT1CshnZKX` will be copied to the same collection `test` 
but with the name `doc4` (option `-c`). All nested collections and documents will also be copied.

⚠️ It's important to understand that the values of the '$createTime' and '$updateTime' fields will not be 
written to the Firestore document, because Firestore ignores these values and overwrites them automatically.

ℹ️ You can delete the meta-data field $name of the document or set it to null. In this case Firestore will 
assign random unique id to this document.


# del-doc Command

It is used to delete a document and all its nested collections and documents.

```bash
dart run fs_service del-doc test/lUAEoKptpXKT1CshnZKX --project=myProject
```

Be careful, as a result of the operation, data is irretrievably destroyed.


# get-col, add-col and del-col Commands

They work similarly to the `get-doc`, `add-doc`, and `del-doc` commands, but are designed to work with collections.

# Detailed information

You can read the detailed information about the tool and each of the command with the following commands

```bash
dart run fs_service --help
```

```bash
dart run fs_service help add-doc
```
