# /webmail/www/util-pages/header-display.tcl
# Displays the headers for a given message.
# @author Erik Bielefeldt (erik@arsdigita.com)
# @creation-date 2000-01-03
# @cvs-id $Id$
#
# msg_id:integer,notnull
# { header_display_style "short" }
#
# properties:
#   headers:multirow
#   refs:multirow

template::multirow create headers name value
template::multirow create refs count ref_msg_id

foreach header $message_headers {
    template::multirow append headers [lindex $header 0] [lindex $header 1]
}

foreach ref $references {
    template::multirow append refs [lindex $references 0] [lindex $references 1]
}

ad_return_template


