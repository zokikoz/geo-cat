English | [Русский](./README-ru.md)

# geo-cat
GeoJSON files concatenator.

Utility to combine and simple transform GeoJSON files.

## Usage
By default, when launched, the script scans the current directory to find files with the .geojson extension.
Then it merges all the files it finds and saves the result to the file **result.geojson**.

### Options
```
geo-cat.rb [-fn] [-d source_dir] [-r result_file]
```

```-r``` - Sets the name of the output file and it path.
```-d``` - Sets the directory to search for GeoJSON files. If the output file is not set it will save result.geojson in this folder.
```-f``` - Generates formatted output file.
```-n``` - Stores the source file name in the feature properties.
