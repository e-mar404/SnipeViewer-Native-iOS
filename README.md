#  Snipe Viewer (Native iOS)

## To-Do\'s: 

### Template
<details>
## <summary> File name </summary>

<br>

* [ ] task to be done with that file
* [x] task that has been completed on that file
</details>

### Project wide:
* [ ] comment code 
* [ ] widget to open app from lock screen

### LoginView.swift
* [ ] make sure password visibility set to always false (sometimes when app open password is visible)

### AssetInfoView.swift
* [ ] work on alert/error message when error is thrown from Snipe.getAsset()

### Snipe.swift
* [ ] restructure code to be able to add in asset actions (rename and check in/out)
* [x] add error handling for Snipe API
    - case 1: [name, not assigned]
    - case 2: [no name, not assigned]
    - case 3: [name, assigned]
    - case 4: [no name, assigned]
    - case 5: [does not exist] 
* [x] restructure Asset object to be able to handle errors
    - made new struct to store the status to not have a lot of props be optional in Asset
    - getAsset func is now getAssetfunc(params) async trows -> (status: SnipeError.AssetStatus?, asset: Asset)
* [ ] catch other status codes/error codes from API calls (e.g "Unauthorized or unauthenticated")

