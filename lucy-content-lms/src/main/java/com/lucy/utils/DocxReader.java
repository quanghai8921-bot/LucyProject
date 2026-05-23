package com.lucy.utils;

import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.List;

import org.apache.poi.xwpf.usermodel.IBodyElement;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFTable;
import org.apache.poi.xwpf.usermodel.XWPFTableCell;
import org.apache.poi.xwpf.usermodel.XWPFTableRow;

public class DocxReader {
    public List<String> readParagraphs(File file) {
        List<String> lines = new ArrayList<String>();

        try (FileInputStream fis = new FileInputStream(file);
                XWPFDocument document = new XWPFDocument(fis)) {

            readBodyElements(document, lines, false);
        } catch (Exception e) {
            System.out.println("Loi khi doc file: " + file.getName());
            e.printStackTrace();
        }

        return lines;
    }

    public List<String> readRawLinesByEnter(File file) {
        List<String> lines = new ArrayList<String>();

        try (FileInputStream fis = new FileInputStream(file);
                XWPFDocument document = new XWPFDocument(fis)) {

            readBodyElements(document, lines, true);
        } catch (Exception e) {
            System.out.println("Loi khi doc file: " + file.getName());
            e.printStackTrace();
        }

        return lines;
    }

    private void readBodyElements(XWPFDocument document, List<String> lines, boolean rawByEnter) {
        for (IBodyElement element : document.getBodyElements()) {
            if (element instanceof XWPFParagraph paragraph) {
                addText(lines, paragraph.getText(), rawByEnter);
                continue;
            }

            if (element instanceof XWPFTable table) {
                addTable(lines, table, rawByEnter);
            }
        }
    }

    private void addTable(List<String> lines, XWPFTable table, boolean rawByEnter) {
        for (XWPFTableRow row : table.getRows()) {
            for (XWPFTableCell cell : row.getTableCells()) {
                addText(lines, cell.getText(), rawByEnter);
            }
        }
    }

    private void addText(List<String> lines, String text, boolean rawByEnter) {
        if (text == null || text.trim().isEmpty()) {
            return;
        }

        if (rawByEnter) {
            lines.add(text.replaceAll("\\R+", " ").trim());
            return;
        }

        String[] splitLines = text.split("\\R");
        for (String line : splitLines) {
            if (line != null && !line.trim().isEmpty()) {
                lines.add(line.trim());
            }
        }
    }
}
