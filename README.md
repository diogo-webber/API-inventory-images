[API_download]: https://github.com/diogo-webber/API-inventory-images/releases/latest/download/inv_images_API.lua
[mod_workshop]: https://steamcommunity.com/sharedfiles/filedetails/?id=2840451757



<img src="https://steamuserimages-a.akamaihd.net/ugc/1901100139831031404/934667EB9D759355529C3D93C0532B9F007217C8/" align="left" width="185px"/>

# [API] Inventory Images

> An API for mod development, written in Lua, for the Klei Entertainment's game, Don't Starve.

<br><br><br>



## Setup:

The API can be imported in 2 ways:

<dl><dd><dl><dd><dl>
<details>

<summary><h4>1. Having the API in your mod files:</h4></summary>
  
  <dl><dd><dl><dd>

  1. [**Download**][API_download] the API file.
  2. Put the downloaded file in your mod files.

  3. Import it with the `modimport` function.
    
<dl><dd><dl><dd><dl><dd><dl>

  ```py
    modimport("path/to/inv_images_API.lua")
  ```
  
</dl></dd></dl></dd></dl></dd></dl>
  
</dd></dl></dd></dl>

</details><details>
<summary><h4> 2. Using the workshop mod as a dependency:</summary></h4>
  
  <dl><dd><dl><dd>
  
  1. Add the [**mod**][mod_workshop] as a dependency on your mod's workshop page.

<dl><dd><dl><dd><dl><dd><dl>
      
<img src="https://i.imgur.com/8KUNTM9.png" width="25%"/>
    
</dl></dd></dl></dd></dl></dd></dl>
    
  2. Import it with the `modimport` function.
    
<dl><dd><dl><dd><dl><dd><dl>
  
```py
  modimport("../workshop-2840451757/inv_images_API.lua")
```
  
</dl></dd></dl></dd></dl></dd></dl>
    
<br>
    
  `Obs:` This method is good for keeping the API up to date.
    
<br>
  
</details>
    
</dd></dl></dd></dl>
  
</dl></dd></dl></dd></dl>



## Usage:

Simply call this function:

```py
   AddInventoryItemAtlas(atlas_path, assets_table)
```

### Function documentation:

<dl><dd><dl><dd><dl><dd>

<blockquote>Adds a global inventory items atlas, compatible with mini signs, crafts, ingredients and shelves.</blockquote>


#### **Parameters:**

  <dl><dd>
    
- `atlas_path` (string) -  The xml file path.
- `assets_table` (table) - The "Assets" table, to load the atlas assets. Not required.
  </dd></dl>

</dd></dl></dd></dl></dd></dl>

 <br>
 
 ```py
    Example: AddInventoryItemAtlas("inventoryimages.xml", Assets)
```
<br>

## Usage Exemples: 

- These are just examples! Your mod doesn't need to be organized this way.

<dl><dd><dl><dd><dl>
<details>

<summary><h4>1. Having the API in your mod files:</h4></summary>
  
  <dl><dd><dl><dd>

  It also demonstrates the use of the `AddInventoryItemAtlas` load assets feature.

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
        >> AddInventoryItemAtlas("images/itemicons.xml", Assets)
```
  
</dd></dl></dd></dl>

</details><details>
<summary><h4> 2. Using the workshop mod as a dependency:</summary></h4>
  
  <dl><dd><dl><dd>
  
  It also demonstrates the `NOT` use of `AddInventoryItemAtlas` load assets feature. Notice the `ATLAS BUILD` asset.
    
```py
📁 mod_folder/
    📁 images/
        📄 myinventoryimages.xml
        🌆 myinventoryimages.tex
        
    📄 modmain.lua
        >> Assets = {
              Asset("ATLAS", "images/myinventoryimages.xml"),
              Asset("IMAGE", "images/myinventoryimages.tex"),
              Asset("ATLAS_BUILD", "images/myinventoryimages.xml", 256),
           }
        
        >> modimport("../workshop-2840451757/inv_images_API.lua")
        >> AddInventoryItemAtlas("images/myinventoryimages.xml")
```
   
<br>
  
</details>
    
</dd></dl></dd></dl>
  
</dl></dd></dl></dd></dl>

<hr>

<details><summary align="center"><h3>In Game Picture:</h3></summary>

<p align="center">
  <img src="https://steamuserimages-a.akamaihd.net/ugc/1901100139830286204/6E2494D49D532FB78E893583322CC68AA9506A83/" alt="Preview Image" width=70%/>
</p>

</details>
<br>

## 📜 License
This project is under MIT license. See the [**LICENSE**](LICENSE) file for more details.
