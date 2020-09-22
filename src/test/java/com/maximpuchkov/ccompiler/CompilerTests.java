//  CompilerTests.java
//  com.maximpuchkov.ccompiler.CompilerTests
//
//  Created by Maxim Puchkov on 2020-09-21.
//  Copyright © 2020 Maxim Puchkov. All rights reserved.

package com.maximpuchkov.ccompiler;


import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class CompilerTests {

    private final Compiler compiler = new Compiler();

    @Test
    public void CompilerExampleTest() {
        assertTrue(true);
    }

    @Test
    public void CompilerIntTest() {
        int num = 1;
        assertEquals(num, compiler.num);
    }

    @Test
    public void CompilerStrTest() {
        String str = "Hello, Java";
        assertEquals(str, compiler.str);
    }
}
