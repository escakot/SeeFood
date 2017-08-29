<p align="center">
<img src="Images/SeeFood.png" alt="Logo">
</p>

## Summary
SeeFood is an iOS app built using Swift. It allows users to find photos of food posted by other users in an organized/categorized manner. Therefore, users can view the photo of the food they're interested in ordering. Stack used are Google Places API, Facebook API, Clarifai API, Cocoapods and Parse database on Heroku for backend.

___

## Data Stored using Parse on Heroku
All data contains creation date
- Restaurant
  - ID (Identifier to match with Google Places API)
  - Name
  - One-to-Many Menu Items
- MenuItems
  - Title
  - One-to-Many Reviews
  - One-to-One Restaurant
- Reviews
  - User (who created the review) 
  - Image Data File
  - One-to-Many Tags
  - One-to-One MenuItem
- Tags
  - One-to-One Review
  - CenterX Location (percentage image size to allow scalability from iPhone to iPads)
  - CenterY Location (percentage image size to allow scalability from iPhone to iPads)

___

# Preview

### Login & Sign Up
User data is stored using Parse or user can login using Facebook API.

<img src="Images/Login.png" alt="Login" width="280" height="490"><img src="Images/Sign-Up.png" alt="Sign-Up" width="280" height="490"><img src="Images/Facebook-Login.png" alt="Facebook-Login" width="280" height="490">

### Finding a Restaurant
- Restaurants are found using Google Places API and a record stored using Parse.
- Search Bar can be used to search for specific restaurants.

<img src="Images/Restaurant-List.png" alt="Restaurant-List" width="280" height="490"><img src="Images/Restaurant-Map.png" alt="Restaurant-Map" width="280" height="490"><img src="Images/Restaurant-Search-Area.png" alt="Restaurant-Search-Area" width="280" height="490">

### Finding a Menu Item
- Menu Items, Photos and Tags are stored using Parse.
- Force touch is available to preview an item in the gallery view.

<img src="Images/Menu-Gallery.png" alt="Menu-Gallery" width="280" height="490"><img src="Images/Menu-List.png" alt="Menu-List" width="280" height="490">

<img src="Images/Pad-Thai.png" alt="Pad-Thai" width="280" height="490"><img src="Images/Cheese-Platter.png" alt="Cheese-Platter" width="280" height="490">

### Posting a Photo
- Users can upload a photo using Camera or Photo Library. 
- Login is required to post a photo.
- Initial Tags are generated using photo recognition from Clarifai API.
- Users can add custom tags or drag and drop tags to the photo.
- Autocomplete is added to prevent duplicate Menu Items.

<img src="Images/Upload-Photo.png" alt="Upload-Photo" width="280" height="490"><img src="Images/Clarifai-Tags.png" alt="Clarifai-Tags" width="280" height="490"><img src="Images/Drag-Drop-Tags.png" alt="Drag-Drop-Tags" width="280" height="490">
<img src="Images/Adding-Tags.png" alt="Adding-Tags" width="280" height="490"><img src="Images/Item-Autocomplete.png" alt="Item-Autocomplete" width="280" height="490"><img src="Images/Item-Autocomplete-2.png" alt="Item-Autocomplete-2" width="280" height="490">

### Potential Problems & Improvements
1. Get users to provide food ratings
    - Problem: Difficult as users post photos before trying to food
    - Solution: Notification to rate the food 1-2 hours after the posting
2. Integrate social media sharing (Use photo tags for hashtags)
3. Search for food based on Tags or Menu Title
