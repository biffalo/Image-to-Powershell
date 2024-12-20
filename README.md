# 🖼️ Image-to-Console Renderer

This PowerShell script takes an image file, resizes it to fit your terminal window, and prints it using colored Unicode characters. It's a neat way to display images directly in your console!

## ✨ Features

- **Adaptive Scaling**: Choose between filling the terminal or maintaining aspect ratio to fit the console dimensions.
- **Colorful Output**: The script uses ANSI escape sequences to render the image in full color (where supported).
- **Wide Format Support**: Any image format supported by System.Drawing on your system can be used (e.g., PNG, JPG, BMP).

## 🔧 Requirements

- **PowerShell**: Compatible with Windows PowerShell 5.1.  
    *For PowerShell 7 (Core) environments, `System.Drawing` may require additional setup.*
- **Console Support**: ANSI colors are required for best results. Most modern terminals support them.

## 💻 Usage

> .\\RenderImage.ps1 "path\\to\\your\\image.jpg"

**Parameters:**

- `-ImageFile` (Required): Path to the image file you want to render.
- `-Fit` (Optional):
    - **Fit**: Maintain aspect ratio and scale image to fit within the console window.
    - **FillTerminal**: Stretch the image to completely fill the console window.

**Examples:**

> \# Render image maintaining aspect ratio  
> .\\RenderImage.ps1 "C:\\Images\\myphoto.png" 
> 
> \# Render image filling the entire terminal (no aspect preservation)  
> .\\RenderImage.ps1 -ImageFile "C:\\Images\\myphoto.png" -Fit FillTerminal
