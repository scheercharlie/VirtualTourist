//
//  ImageTaskDownloadedDelegate.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 10/17/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//
//Image download delegate pattern created by Alex Akrimpai
//Source: https://codingwarrior.com/2018/02/05/ios-display-images-in-uicollectionview/

import UIKit

protocol ImageTaskDownloadedDelegate {
    func imageDownloaded(position: Int)
}
