//
//  GetImageURL.swift
//  Assignment2
//
//  Created by user276180 on 11/21/25.
//

import Foundation

func GetImageURL(id: String, index: Int) -> URL?{
    let urlString = "https://easterbilby.net/birdle/\(id)\(index).jpg"
    return URL(string: urlString)
}
