//
//  MapViewDelegate.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import MapKit

class MapViewDelegate: NSObject, MKMapViewDelegate {

    let fillColor: UIColor
    let strokeColor: UIColor

    init(fill: UIColor, stroke: UIColor) {
        self.fillColor = fill
        self.strokeColor = stroke
    }

    //render the polygon to the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if overlay is MKCircle {
            let circle = overlay as! MKCircle
            let renderer = MKCircleRenderer(circle: circle)
            renderer.fillColor = UIConstants.mapBeige
            renderer.alpha = 0.1
            renderer.lineDashPattern = [2, 5];
            renderer.strokeColor = .black
            return renderer
        }

        if overlay is MKPolygon {
            let custom = (overlay as! CustomPolygon)
            let polygonView = MKPolygonRenderer(overlay: custom)
            polygonView.lineWidth = 0.75
            polygonView.alpha = 0.9
            polygonView.strokeColor = strokeColor // UIColor(red: 0.15, green: 0.1, blue: 0.01, alpha: 1.0)
            if custom.userGuessed == false {
                polygonView.fillColor = fillColor
            } else {
                polygonView.fillColor = .clear
            }
            return polygonView
        }
        return MKOverlayRenderer()
    }

    //show labels instead of annotations on the page
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId: String = "itemAnnotation"
        var aView: MKAnnotationView
        if let av = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) {
            av.annotation = annotation
            aView = av
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            let lbl = UILabel()
            lbl.tag = 20
            av.addSubview(lbl)
            aView = av
        }
        let lbl: UILabel = (aView.viewWithTag(20) as! UILabel)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.addConstraint(
            NSLayoutConstraint(
                item: lbl,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 21
            )
        )
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 3
        lbl.textAlignment = .center
        lbl.text = " \(annotation.title!!) "
        lbl.font = UIConstants.josefinSansRegular(size: 15)
        lbl.textColor = .black
        lbl.backgroundColor = UIConstants.mapBeige
        lbl.sizeToFit()
        return aView
    }

}
