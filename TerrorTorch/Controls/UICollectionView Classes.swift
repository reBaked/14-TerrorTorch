//
//  UICollectionViewRowLayout.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 7/29/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

/**
*  Laysout cells of collection view in a row
*  Cells have same height as collection view and are sqare
*  Selected item is the cell that's in the middle of the collection view.
*  Only one section supported. No support for headers, footers or supplementary views.
*/
class UICollectionViewRowLayout: UICollectionViewLayout {
    var minimumCellSpacing:CGFloat!;            //Default spaces cells so half of previous and next cells are visible.
    var leftInset:CGFloat!                      //Default spacing places center of first cell at center of collection view
    var rightInset:CGFloat!;                    //Default spacing places center of last cell at center of collection view
    var itemSize:CGSize!                        //Default square dimensions with height equal to height of collection view
    private var _currentItem = 0;               //Index of item within center of collection view
    
    var currentItem:NSIndexPath{                //Indexpath of item within center of collection view
        get{
            return  NSIndexPath(forItem: _currentItem, inSection: 0);
        }
    }
    
    private var _numItems:Int{
        get{
            return self.collectionView.numberOfItemsInSection(0);
        }
    }
    
    //All calculations are done once and shouldn't be changed after
    override func prepareLayout() {
        let bounds = self.collectionView.bounds;
        itemSize = CGSizeMake(bounds.height, bounds.height);
        leftInset = bounds.width/2 - (itemSize.width/2);
        rightInset = leftInset;                                             //Alfred likes symmetry
        minimumCellSpacing = (bounds.width - itemSize.width*2) * 0.5;
        
        if(minimumCellSpacing < 0) {                                        //Sometimes cells are too big to make atleast 2 cells visible at a time
            minimumCellSpacing = (bounds.width - itemSize.width) * 0.5;     //Make sure atleast one cell is always visible
        }
        
        println("UICVRowLayout config dump - leftInset: \(leftInset) rightInset: \(rightInset) minimumCellSpacing: \(minimumCellSpacing) itemSizeWidth: \(itemSize.width) numItems: \(_numItems)");
    }
    
    
    override func collectionViewContentSize() -> CGSize {
        let contentWidth = leftInset + itemSize.width * CGFloat(_numItems) + minimumCellSpacing * CGFloat(_numItems - 1) + rightInset;
        let contentHeight = self.collectionView.bounds.height;
        
        return CGSizeMake(contentWidth, contentHeight);
    }
    
    //Only worried about positioning cells along the x axis. Spaces cells according to properties of layout
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath!) -> UICollectionViewLayoutAttributes! {
        
        let result = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath);
        var x = (indexPath.item == 0) ? leftInset : leftInset + itemSize.width * CGFloat(indexPath.item) + minimumCellSpacing * CGFloat(indexPath.item);    // Position cell
        result.frame = CGRectMake(x, 0, itemSize.width, itemSize.height);
        return result;
    }
    
    //Dynamically retrieves attributes of cells in rectangle by dividing rectangle into indexes
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]! {
        
        let elementWidth = itemSize.width + minimumCellSpacing;
        
        //Start point for comparison is after left inset spacing
        let offsetMinX = rect.minX + leftInset;
        let offsetMaxX = rect.maxX + leftInset;
        
        //Divide offsets by elementWidth to split the rectangle into section representing our indexes
        let firstIndex = Int(offsetMinX/elementWidth);
        let lastIndex = Int(offsetMaxX/elementWidth)-1;
        
        //Corrections if rectangle bounces past bounds of our layout
        let firstItem = (firstIndex < 0) ? 0 : firstIndex;
        let lastItem = (lastIndex > _numItems-1) ? _numItems-1 : lastIndex;
    
        //Final result of calculations
        println("UICVRowLayout rect dump - minX: \(rect.minX) maxX: \(rect.maxX) elementWidth: \(elementWidth) firstItem: \(firstItem) lastItem: \(lastItem)");
        
        //Retrieve attributes for cells appearing within rectangle
        var result = [UICollectionViewLayoutAttributes]();
        for index in firstItem...lastItem{
            result.append(self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)));
        }
        
        return result;
    }
    
    //Snaps content to position the center of the nearest cell at the center of the view
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let elementWidth = itemSize.width + minimumCellSpacing;
        let offsetX = proposedContentOffset.x + leftInset;                  //Start point for comparison is after left inset spacing
        
        _currentItem = Int(offsetX/elementWidth);                           //Calculate nearest item and make it the current item
        
        let attributes = self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: _currentItem, inSection: 0));
        return CGPointMake(attributes.frame.minX - leftInset, 0);           //Return center of current item to reposition content offset
    }
}

extension UICollectionView{
    //Will only return a value if collection view's layout is a UICollectionViewRowLayout
    var selectedItem:NSIndexPath?{
        get{
            if let layout = self.collectionViewLayout as? UICollectionViewRowLayout{
                return layout.currentItem;
            } else {
                return nil;
            }
        }
    }
}

class UICollectionViewCellStyleImage: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
}