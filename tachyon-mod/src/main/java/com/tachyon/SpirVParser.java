package com.tachyon;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.List;

public class SpirVParser {
    public static List<String> getEntryPoints(byte[] spvBytes) {
        List<String> entryPoints = new ArrayList<>();
        if (spvBytes.length < 20) return entryPoints;
        
        ByteBuffer buf = ByteBuffer.wrap(spvBytes).order(ByteOrder.LITTLE_ENDIAN);
        int magic = buf.getInt();
        if (magic != 0x07230203) return entryPoints; // Not SPIR-V
        
        buf.position(20); // Skip header (5 words)
        
        while (buf.remaining() >= 4) {
            int word = buf.getInt();
            int opCode = word & 0xFFFF;
            int wordCount = word >>> 16;
            
            if (wordCount == 0) break;
            if (buf.remaining() < (wordCount - 1) * 4) break;
            
            if (opCode == 15) { // OpEntryPoint
                int execModel = buf.getInt(); // Word 1
                int id = buf.getInt(); // Word 2
                
                // Read string (starts at Word 3)
                StringBuilder sb = new StringBuilder();
                boolean done = false;
                int wordsRead = 2; // Read 2 words so far (execModel, id)
                while (!done && wordsRead < wordCount - 1) {
                    int strWord = buf.getInt();
                    wordsRead++;
                    for (int i = 0; i < 4; i++) {
                        char c = (char)((strWord >> (i * 8)) & 0xFF);
                        if (c == 0) {
                            done = true;
                            break;
                        }
                        sb.append(c);
                    }
                }
                
                String modelStr = execModel == 0 ? "Vertex" : (execModel == 4 ? "Fragment" : "Other(" + execModel + ")");
                entryPoints.add(modelStr + ": " + sb.toString());
                
                // Skip remaining words of this instruction
                int remainingToSkip = (wordCount - 1) - wordsRead;
                buf.position(buf.position() + remainingToSkip * 4);
            } else {
                buf.position(buf.position() + (wordCount - 1) * 4);
            }
        }
        
        return entryPoints;
    }
}
