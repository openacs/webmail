/* /webmail/java/StringBufDataSource.java
 *
 *  part of the webmail ACS module
 *  written by Erik Bielefeldt (erik@arsdigita.com)
 *  2001-01-17
 *  
 *  Note: this object only partially implements the class DataSource
 *  because the function getOutputStream() always returns null.
 *  Because this is only used for setting the content of 
 *  an outgoing message to be a StringBuffer, it works fine.
 *  See MessageComposer.getForwardedMessage() to see how it is used.
*/

package com.arsdigita.mail;

import javax.activation.*;
import java.io.*;

public class StringBufDataSource implements DataSource {
    protected StringBuffer buffer;
    protected String contentType;
    protected String name;

    public StringBufDataSource(StringBuffer buffer, String contentType, String name) {
	this.buffer = buffer;
	this.contentType = contentType;
	this.name = name;
    }

    public InputStream getInputStream()
	throws IOException {
	return new StringBufferInputStream(buffer.toString());
    }

    public OutputStream getOutputStream()
	throws IOException {
	return null;
    }
    
    public String getContentType() {
	return contentType;
    }

    public String getName() {
	return name;
    }
};

