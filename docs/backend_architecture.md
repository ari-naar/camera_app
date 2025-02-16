# Firebase Backend Architecture

## Database Structure

### Firestore Collections

1. **users**
   - Document ID: `userId` (from Firebase Auth)
   - Fields:
     - `username`
     - `displayName`
     - `profilePicUrl`
     - `createdAt`
     - `lastActive`
     - `friendIds` (array)
     - `friendRequests` (array)
     - `deviceTokens` (for push notifications)

2. **photos**
   - Document ID: auto-generated
   - Fields:
     - `userId` (reference to user)
     - `imageUrl`
     - `caption`
     - `timestamp`
     - `likes` (array of userIds)
     - `comments` (subcollection)
     - `visibility` (public/friends-only)
     - `location` (optional)

3. **dailyPhotos**
   - Document ID: `YYYY-MM-DD_userId`
   - Fields:
     - `userId`
     - `photoId` (reference to photos collection)
     - `timestamp`
     - `status` (posted/missed)

### Firebase Storage Structure

```
/users
  /{userId}
    /profile
      - profile_picture.jpg
    /photos
      /{photoId}
        - original.jpg
        - thumbnail.jpg
```

## Core Functionality

### Image Storage and Processing
1. When user takes a photo:
   - Upload original image to Firebase Storage
   - Generate and store thumbnail
   - Create entry in photos collection
   - Create entry in dailyPhotos collection
   - Images stored with content-based hash names to prevent duplicates

### Feed Management
1. Fetching Feed:
   - Query dailyPhotos collection for friend's posts within last 24 hours
   - Implement pagination (20 photos per load)
   - Sort by timestamp
   - Filter based on friendship status

### User Management and Friendship
1. Friend System:
   - Send friend request (update recipient's friendRequests array)
   - Accept friend request:
     - Remove from friendRequests
     - Add to both users' friendIds arrays
   - Reject/Remove friend:
     - Remove from friendIds arrays

2. User Search:
   - Implement search by username/displayName
   - Use Firebase's full-text search capabilities
   - Consider implementing Algolia for better search experience

### Security Rules Structure

```
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read public profiles but only edit their own
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }

    // Photos can be viewed by friends, edited by owner
    match /photos/{photoId} {
      allow read: if isOwnerOrFriend(resource.data.userId);
      allow write: if request.auth.uid == resource.data.userId;
    }

    // Daily photos visible to friends only
    match /dailyPhotos/{dailyPhotoId} {
      allow read: if isOwnerOrFriend(resource.data.userId);
      allow write: if request.auth.uid == resource.data.userId;
    }
  }
}
```

## Performance Considerations

1. **Caching Strategy**
   - Implement local caching for feed
   - Cache user friend lists
   - Store frequently accessed photos in local storage

2. **Optimization**
   - Use cloud functions for image processing
   - Implement lazy loading for feed
   - Use Firebase indexes for common queries
   - Compress images before upload

## Push Notifications

1. **Notification Events**
   - New friend requests
   - Friend request accepted
   - Daily reminder to post photo
   - Comments on photos
   - Likes on photos

## Data Backup and Recovery

1. **Backup Strategy**
   - Daily backup of Firestore data
   - Weekly backup of Storage data
   - Implement version control for user data

## Rate Limiting and Quotas

1. **Limitations**
   - Max image size: 10MB
   - Max daily uploads: 5 per user
   - Search queries: 100 per minute per user
   - API calls: 1000 per minute per user 