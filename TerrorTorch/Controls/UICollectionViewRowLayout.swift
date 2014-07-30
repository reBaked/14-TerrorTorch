//
//  UICollectionViewRowLayout.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 7/29/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//
class UICollectionViewRowLayout: UICollectionViewLayout {
    var minimumCellSpacing:CGFloat!;
    var leftInset:CGFloat!
    var rightInset:CGFloat!;
    var itemSize:CGSize!
    
    private var numItems:Int{
        get{
            return self.collectionView.numberOfItemsInSection(0);
        }
    }
    
    override func prepareLayout() {
        let bounds = self.collectionView.bounds;
        itemSize = CGSizeMake(bounds.height, bounds.height);
        leftInset = bounds.width/2 - (itemSize.width/2);
        rightInset = leftInset;
        minimumCellSpacing = (bounds.width - itemSize.width*2) * 0.5;
        if(minimumCellSpacing < 0) {
            minimumCellSpacing = (bounds.width - itemSize.width) * 0.5;
        }
        println("UICVRowLayout config dump - leftInset: \(leftInset) rightInset: \(rightInset) minimumCellSpacing: \(minimumCellSpacing) itemSizeWidth: \(itemSize.width) numItems: \(numItems)");
    
    }
    
    override func collectionViewContentSize() -> CGSize {
        let contentWidth = leftInset + itemSize.width * CGFloat(numItems) + minimumCellSpacing * CGFloat(numItems - 1) + rightInset;
        let contentHeight = self.collectionView.bounds.height;
        
        return CGSizeMake(contentWidth, contentHeight);
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath!) -> UICollectionViewLayoutAttributes! {
        let result = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath);
        var x = (indexPath.item == 0) ? leftInset : leftInset + itemSize.width * CGFloat(indexPath.item) + minimumCellSpacing * CGFloat(indexPath.item);
        result.frame = CGRectMake(x, 0, itemSize.width, itemSize.height);
        return result;
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]! {
        let elementWidth = itemSize.width + minimumCellSpacing;
        let offsetMinX = rect.minX + leftInset;
        let offsetMaxX = rect.maxX + leftInset;
        
        let firstItem = Int(offsetMinX/elementWidth);
        let lastIndex = Int(offsetMaxX/elementWidth)-1;
        let lastItem = (lastIndex > numItems-1) ? numItems-1 : lastIndex;
        
        println("UICVRowLayout rect dump - minX: \(rect.minX) maxX: \(rect.maxX) elementWidth: \(elementWidth) firstItem: \(firstItem) lastItem: \(lastItem)");
        var result = [UICollectionViewLayoutAttributes]();
        for index in firstItem...lastItem{
            result += self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0));
        }
        
        return result;
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let offsetX = proposedContentOffset.x + leftInset;
        let elementWidth = itemSize.width + minimumCellSpacing;
        let item = Int(offsetX/elementWidth);
        
        let attributes = self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: item, inSection: 0));
        return CGPointMake(attributes.frame.minX - leftInset, 0);
    }
}
