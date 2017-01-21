//
//  DHSlideControl.swift
//  Narrative
//
//  Created by Ashish Keshan on 1/12/17.
//  Copyright © 2017 Scope. All rights reserved.
//

import UIKit

class DHSlideControl: UIControl {
    
    var selectedIndex: Int
    var titles = [String]()
    
    
    var color: UIColor? {
        didSet {
            backgroundColor = color
            if let color = color {
                rightGradientLayer.colors = [color.withAlphaComponent(0.1).cgColor, color.cgColor]
                leftGradientLayer.colors = [color.withAlphaComponent(0.1).cgColor, color.cgColor]
            }
            tintColor = color
        }
    }
    
    fileprivate let scrollView: UIScrollView
    fileprivate let labelHostView: UIView
    fileprivate var rightBlendView: UIView
    fileprivate let leftBlendView: UIView
    fileprivate let leftGradientLayer: CAGradientLayer
    fileprivate let rightGradientLayer: CAGradientLayer
    
    fileprivate var xOffsetAtStart: CGFloat?
    
    init(titles: [String]) {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.clipsToBounds = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.showsHorizontalScrollIndicator = false
        
        labelHostView = UIView()
        labelHostView.translatesAutoresizingMaskIntoConstraints = false
        
        let controllColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.7, alpha: 1.0)
        rightBlendView = UIView()
        rightBlendView.translatesAutoresizingMaskIntoConstraints = false
        rightGradientLayer = CAGradientLayer()
        rightGradientLayer.colors = [controllColor.withAlphaComponent(0).cgColor, controllColor.cgColor]
        rightGradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        rightGradientLayer.endPoint = CGPoint(x: 0.2, y: 0.5)
        //rightBlendView.layer.addSublayer(rightGradientLayer)
        
        leftBlendView = UIView()
        leftBlendView.translatesAutoresizingMaskIntoConstraints = false
        leftGradientLayer = CAGradientLayer()
        leftGradientLayer.colors = [controllColor.withAlphaComponent(0).cgColor, controllColor.cgColor]
        leftGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        leftGradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
        //leftBlendView.layer.addSublayer(leftGradientLayer)
        
        selectedIndex = 0
        
        super.init(frame: .zero)
        backgroundColor = controllColor
        tintColor = controllColor
        clipsToBounds = true
        
        self.titles = titles
        scrollView.delegate = self
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(DHSlideControl.didPan(_:))))
        
        let imageView = UIImageView(image: triangleImage(controllColor))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        scrollView.addSubview(labelHostView)
        addSubview(rightBlendView)
        addSubview(leftBlendView)
        addSubview(imageView)
        
        var layoutConstraints = [NSLayoutConstraint]()
        
        var previousLabel: UILabel?
        for (index, string) in titles.enumerated() {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            labelHostView.addSubview(label)
            label.text = string
            label.textAlignment = .center
            label.backgroundColor = .white
            
            layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[label]-20-|", options: [], metrics: nil, views: ["label": label])
            
            if previousLabel == nil {
                layoutConstraints.append(label.leadingAnchor.constraint(equalTo: labelHostView.leadingAnchor))
            } else {
                layoutConstraints.append(label.leadingAnchor.constraint(equalTo: (previousLabel?.trailingAnchor)!))
                layoutConstraints.append(label.widthAnchor.constraint(equalTo: (previousLabel?.widthAnchor)!))
            }
            previousLabel = label
            
            if index == titles.count-1 {
                layoutConstraints.append(label.trailingAnchor.constraint(equalTo: labelHostView.trailingAnchor))
            }
        }
        
        let views = ["scrollView": scrollView, "host": labelHostView, "right": rightBlendView, "left": leftBlendView]
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "|[right(70)][scrollView][left(70)]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views)
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: views)
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "|[host]|", options: [], metrics: nil, views: views)
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[host]|", options: [], metrics: nil, views: views)
        layoutConstraints.append(imageView.centerXAnchor.constraint(equalTo: centerXAnchor))
        layoutConstraints.append(imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 20))
        NSLayoutConstraint.activate(layoutConstraints)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //    print(scrollView.frame)
        labelHostView.widthAnchor.constraint(equalToConstant: CGFloat(titles.count)*scrollView.frame.size.width).isActive = true
        labelHostView.heightAnchor.constraint(equalToConstant: scrollView.frame.size.height).isActive = true
        
        leftGradientLayer.frame = leftBlendView.bounds
        rightGradientLayer.frame = rightBlendView.bounds
    }
    
    func didPan(_ sender: UIPanGestureRecognizer) {
        let xTranslation = sender.translation(in: self).x
        
        switch sender.state {
        case .began:
            xOffsetAtStart = scrollView.contentOffset.x
        case .changed:
            if let xOffsetAtStart = xOffsetAtStart {
                scrollView.setContentOffset(CGPoint(x: -xTranslation + xOffsetAtStart, y: 0), animated: false)
            }
        case .ended:
            xOffsetAtStart = nil
            let widthOfLabel = floor(scrollView.contentSize.width/CGFloat(titles.count))
            //      print(scrollView.contentOffset.x/widthOfLabel)
            let offset = max(min(round(scrollView.contentOffset.x/widthOfLabel), CGFloat(titles.count-1)), 0.0)*widthOfLabel
            
            //      scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
            //      let xVelocity = sender.velocityInView(self).x
            //
            //      print(offset-scrollView.contentOffset.x)
            ////      Double(abs(offset-scrollView.contentOffset.x)/50.0)
            //      UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: xVelocity/30, options: [], animations: { () -> Void in
            //        self.scrollView.contentOffset.x = offset
            //        }, completion: nil)
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
            }, completion: { (_) -> Void in
                self.scrollViewDidEndDecelerating(self.scrollView)
            })
            
        default:
            break
        }
    }
    
    func triangleImage(_ color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 240, height: 120), false, 0)
        let polygonPath = UIBezierPath()
        polygonPath.move(to: CGPoint(x: 118, y: 55))
        polygonPath.addLine(to: CGPoint(x: 152, y: 77))
        polygonPath.addLine(to: CGPoint(x: 84, y: 77))
        polygonPath.close()
        color.setFill()
        polygonPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image.withRenderingMode(.alwaysTemplate)
    }
    
}

extension DHSlideControl : UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let widthOfLabel = floor(scrollView.contentSize.width/CGFloat(titles.count))
        selectedIndex = Int(round(scrollView.contentOffset.x/widthOfLabel))
        sendActions(for: .valueChanged)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let widthOfLabel = floor(scrollView.contentSize.width/CGFloat(titles.count))
            selectedIndex = Int(round(scrollView.contentOffset.x/widthOfLabel))
            sendActions(for: .valueChanged)
        }
    }
}
