# HTML Indentation Script

This script is designed to properly indent HTML files for better readability and structure. It automatically formats an input HTML file using a command-line tool.

## Features
- Automatically indents and formats HTML files.
- Preserves the original structure while improving readability.
- Lightweight and easy to use.

## Usage
To format an HTML file, run the following command:

```bash
./script.sh input.html
```

This will output the formatted HTML content to the terminal. To save the changes to the same file:

```bash
./script.sh input.html > formatted.html
mv formatted.html input.html
```

## Example
**Before Formatting:**
```html
<html><body><h1>Title</h1><p>Some text</p></body></html>
```

**After Formatting:**
```html
<html>
  <body>
    <h1>Title</h1>
    <p>Some text</p>
  </body>
</html>
```

## License
This script is released under the MIT License.


