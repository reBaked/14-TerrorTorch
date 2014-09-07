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
    private var _contentAttributes:[UICollectionViewLayoutAttributes] = []
    
    var currentItem:NSIndexPath{                //Indexpath of item within center of collection view
        get{
            return  NSIndexPath(forItem: _currentItem, inSection: 0);
        }
    }
    
    private var _numItems:Int{
        get{
            return self.collectionView!.numberOfItemsInSection(0);
        }
    }

    //All calculations are done once and shouldn't be changed after
    override func prepareLayout() {
        super.prepareLayout();
        
        let bounds = self.collectionView!.bounds;
        self.updateToBounds(self.collectionView!.bounds);
        self.updateLayoutAttributes();
        
    }
    
    override func collectionViewContentSize() -> CGSize {
        let contentWidth = leftInset + itemSize.width * CGFloat(_numItems) + minimumCellSpacing * CGFloat(_numItems - 1) + rightInset;
        let contentHeight = self.collectionView!.bounds.height;
        
        return CGSizeMake(contentWidth, contentHeight);
    }
    
    //Only worried about positioning cells along the x axis. Spaces cells according to properties of layout
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return _contentAttributes[indexPath.item];
    }
    
    //Dynamically retrieves attributes of cells in rectangle by dividing rectangle into indexes
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]?{
        
        var result = [UICollectionViewLayoutAttributes]();
        
        for attribute in _contentAttributes{
            if(CGRectContainsRect(rect, attribute.frame)){
                result.append(attribute);
            }
        }
        
        return result;
    }
    
    //Snaps content to position the center of the nearest cell at the center of the view
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let offsetX = proposedContentOffset.x + leftInset;                  //Start point for comparison is after left inset spacing
        
        for (i, attribute) in enumerate(_contentAttributes){
            if(attribute.frame.contains(CGPointMake(offsetX, 0))){
                _currentItem = i;
                return CGPointMake(attribute.frame.minX - leftInset, 0);
            }
        }
        
        return proposedContentOffset;
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        if(newBounds.height != itemSize.height){
            return true;
        }
        
        return false;
    }
    
    func updateToBounds(bounds:CGRect){
        itemSize = CGSizeMake(bounds.height, bounds.height);
        leftInset = bounds.width/2 - (itemSize.width/2);
        rightInset = leftInset;
        minimumCellSpacing = (bounds.width - itemSize.width*2) * 0.5;
        
        if(minimumCellSpacing < 0) {                                        //Sometimes cells are too big to make atleast 2 cells visible at a time
            minimumCellSpacing = (bounds.width - itemSize.width) * 0.5;     //Make sure atleast one cell is always visible
        } else if(minimumCellSpacing > itemSize.width){
            minimumCellSpacing = itemSize.width;
        }
        
        println("UICVRowLayout layout update dump - leftInset: \(leftInset) rightInset: \(rightInset) minimumCellSpacing: \(minimumCellSpacing) itemSizeWidth: \(itemSize.width) numItems: \(_numItems)");
    }
    
    func updateLayoutAttributes(){
        _contentAttributes.removeAll(keepCapacity: false);
        for item in 0..<_numItems{
            let result = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: item, inSection: 0));
            let x = (item == 0) ? leftInset : leftInset + itemSize.width * CGFloat(item) + minimumCellSpacing * CGFloat(item);
            result.frame = CGRectMake(x, 0, itemSize.width, itemSize.height);
            _contentAttributes.append(result);
        }
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
