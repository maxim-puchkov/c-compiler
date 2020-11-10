//  Symbol.java
//  com.maximpuchkov.ccompiler.Symbol
//
//  Created by Maxim Puchkov on 2020-09-23.
//  Copyright © 2020 Maxim Puchkov. All rights reserved.

package com.maximpuchkov.ccompiler;

public class Symbol {
    private String name;
    private SymbolType type;
    private int symbolId;
    private int tableId;


    public Symbol(String name, SymbolType type) {
        this.name = name;
        this.type = type;
    }
}
