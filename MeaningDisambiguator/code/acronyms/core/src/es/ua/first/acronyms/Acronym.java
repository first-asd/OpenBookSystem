/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.acronyms;

import java.util.List;

/**
 *
 * @author lcanales
 */
public class Acronym {
    private String acronym;
    private List<Integer> start_offset;
    private List<Integer> end_offset;
    private double complexity = 0.0;
    private String definition;

    public Acronym(String acronym, List<Integer> start_offset, List<Integer> end_offset, String definition) {
        this.acronym = acronym;
        this.start_offset = start_offset;
        this.end_offset = end_offset;
        this.definition = definition;
    }

    public String getAcronym() {
        return acronym;
    }

    public List<Integer> getStart_offset() {
        return start_offset;
    }

    public List<Integer> getEnd_offset() {
        return end_offset;
    }

    public double getComplexity() {
        return complexity;
    }

    public String getDefinition() {
        return definition;
    }
}
