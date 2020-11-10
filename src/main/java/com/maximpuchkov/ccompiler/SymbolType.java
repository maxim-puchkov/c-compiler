//  SymbolType.java
//  com.maximpuchkov.ccompiler.SymbolType
//
//  Created by Maxim Puchkov on 2020-09-23.
//  Copyright © 2020 Maxim Puchkov. All rights reserved.

package com.maximpuchkov.ccompiler;

public enum SymbolType {
    INT("INT"),     CHAR("CHAR"),
    STR("STR"),     VOID("VOID"),
    BOOL("BOOL"),   LABEL("LABEL"),
    INVALID("INVALID");

    public final String description;

    SymbolType(String str) {
        this.description = str;
    }

    public String toString() {
        return description;
    }
}
