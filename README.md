<img src="https://steamuserimages-a.akamaihd.net/ugc/1901100139831031404/934667EB9D759355529C3D93C0532B9F007217C8/" align="left" width="185px"/>

<h1 style="padding-left: 200px">[API] Inventory Images</h1>

<blockquote style="padding-left: 20px">An API for mod development, written in Lua, for the Klei Entertainment's game, Don't Starve.</blockquote>

<br><br><br>

## Setup:

1. [**Download**](https://github.com/diogo-webber/API-inventory-images/releases/latest/download/inv_images_API.lua) the API file.
1. Put the downloaded file in your mod files.

2. Import it with the `modimport` function.

```py
  modimport("path/to/inv_images_API.lua")
```

<br>

## Usage:

Simply call this function:

```py
   GLOBAL.AddInventoryItemAtlas(atlas_path, assets_table)
```

### Function documentation:

<dl><dd><dl><dd><dl><dd>

<blockquote>Adds a global inventory items atlas, compatible with mini signs, crafts, ingredients and shelves.</blockquote>


#### **Parameters:**

- ㅤ`atlas_path` (string) -  The xml file path.
- ㅤ`assets_table` (table) - The "Assets" table, to load the atlas assets. Not required.

</dd></dl></dd></dl></dd></dl>

 <br>
 
 ```py
    Example: GLOBAL.AddInventoryItemAtlas("inventoryimages.xml", Assets)
```
<br>

## Usage Exemple: 

```py
📁 mod_folder/
    📁 images/
        📄 itemicons.xml
        🌆 itemicons.tex
        
    📁 scripts/
        📄 inv_images_API.lua
        
    📄 modmain.lua
        >> modimport("scripts/inv_images_API.lua")
        >> Assets = {...}
        >> GLOBAL.AddInventoryItemAtlas("images/itemicons.xml", Assets)
```

This is just an example! Your mod doesn't need to be organized this way.

<br>

<h2 align="center">In Game Picture:</h2>

<p align="center">
  <img src="https://steamuserimages-a.akamaihd.net/ugc/1901100139830286204/6E2494D49D532FB78E893583322CC68AA9506A83/" alt="Preview Image" width=70%/>
</p>

<br>

## 📜 License
This project is under MIT license. See the [**LICENSE**](LICENSE) file for more details.
