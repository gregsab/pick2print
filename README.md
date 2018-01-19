# pick2print
This very simple Adobe Lightroom plugin will help you to choose photos to be printed.  

## How does it work?
Obviously, **pick2print** plugin will not do the whole work for you. You will need to 
review all your photos and rank (e.g assign no. of stars) them according to taste.

Picking photos is done by adding them to a defined _collection_.

Based on the ranking the plugin will choose given number of photos. 
It will start from the best-ranked photos and continue analysis through the lower ranked ones. 
 
 
If number of photos in a rank is lower then number of still needed ones, 
all will be added to the collection.

If number photos which are still required is lower then number of 
pictures which have analyzed rank, they will be chosen randomly.    


### Example
Ranking statistics:
4\* - 7 photos, 3\* - 15 photos, 3\* - 30 photos, 1\* - 62 photos

No. of photos to be picked: **40**

Plugin will select: all 4\* photos, all 3\* photos and 18 _randomly chosen_ 2\* photos.  

### Selection procedure
1. Rank your photos
2. Select set of photos to be considered
3. Launch plugin from Lightroom menu 
4. Review ranking statistcs
5. Decide no. of photos to be picked and collection name
6. Continue by cliking '?' button
