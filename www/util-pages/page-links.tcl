# /webmail/www/util-pages/page-links.tcl
# @author Erik Bielefeldt (erik@arsdigita.com)
# @creation-date 2001-01-04
# @cvs-id $Id$
#
# Parameters: 
#   n_messages
#   cur_page
#   msg_per_page
#   url
#
# Properties:
#   pages:multirow
#   num_pages:onevalue

template::multirow create pages number

set num_pages [expr $n_messages / $msg_per_page]
if { [expr $n_messages % $msg_per_page] != 0 } { incr num_pages }
if { $num_pages == 0 } { set num_pages 1 }

for {set i 1} {$i <= $num_pages} {incr i} {
    template::multirow append pages $i
}

if { [regexp {\?} $url] } {
    set url "$url&"
} else {
    set url "$url?"
}

ad_return_template




