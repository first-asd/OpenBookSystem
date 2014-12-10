/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.acronyms;

import java.util.ArrayList;

/**
 *
 * @author lcanales
 */
class ParamsJSON {
    private String lang;
    private String address;

    public ParamsJSON(String lang, String address) {
        this.lang = lang;
        this.address = address;
    }

    public String getAddress() {
        return address;
    }

    public String getLang() {
        return lang;
    }

    public void setLang(String lang) {
        this.lang = lang;
    }
}
