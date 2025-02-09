This directory contains an example paper and informations 
for preparing manuscripts for the journal Solar Physics.

-- Sample              
SOLA_example_6.tex       Sample paper 
SOLA_example_6.pdf       output after compilation (LaTeX, BibTeX, LaTeX, LaTeX of SOLA_example_6) 

-- Files included at compilation
fig1a.eps                        Four figures
fig1b.eps
fig1c.eps
fig1d.eps
SOLA_bibliography_example.bib    Bibliography


-- Extra information
SOLA_keyword_list.txt
SOLA_example_labels.tex
SOLA_Instructions_for_authors.txt


-- Formatting files  
spr-sola-addons.sty
spr-mp-sola.bst
spr-mp-sola-cnd.bst
SolPhys.bst


-- Template
template.tex

-- Notifications
* spr-sola-addons option "linksfromyear" is tested with:
	1. texlive/2008 - natbib 8.1,   hyperref v6.78f
	2. texlive/2009 - natbib 8.31,  hyperref v6.79a
	3. texlive/2010 - natbib 8.31a, hyperref v6.81g
     When hyperref is loaded make a hyperlink only from year component 
     of the cite command. It solves the problem of overfull boxes when dvips driver is used.
     It might not work with an older natbib packages.
     Citation style should be an author-year, and the hyperref should be loaded somewhere in preamble.
* spr-sola-addons option "natbib" loads a natbib package.



Changes


    * 2010.10.14
          o spr-astr-addons.sty:
               1. entered option "linksfromyear", which loads a natbib and puts a link on a year citation.
    * 2010.05.13
          o spr-mp-sola.bst and spr-mp-sola-cnd.bst:
    * 2010.01.26
          o spr-astr-addons.sty:
               1. entered option "solaenum", which makes enumerated list with italics-roman numerals and a single right-bracket.
    * 2009.06.16
          o spr-mp-sola.bst and spr-mp-sola-cnd.bst:
               1. minor fixes.
    * 2009.06.05
          o spr-mp-sola.bst and spr-mp-sola-cnd.bst:
               1. added letters to the years (in bibliography), if authors and years are the same.
    * 2009.06.04
          o spr-mp-sola.bst and spr-mp-sola-cnd.bst:
               1. added letters to the volume ("CS-" if publisher = "ASP" and "SP-" if publisher = "ESA")
               2. \doiurl in \textsf font
    * 2009.06.03
          o spr-mp-sola.bst and spr-mp-sola-cnd.bst:
               1. added letters to the \citeauthoryear{}{} year section (if the same year)
               2. not cutting letters from the pages any more
          o SolarPhysics.cls :
               1. "," taken off from the \inlinecite
    * 2009.06.02
          o spr-mp-sola.bst and spr-mp-sola-cnd.bst:
               1. doi links out to http://dx.doi.org (using with \usepackage{hyperref}])
    * 2008.06.18
          o natbib option added to spr-sola-addons.sty. Use this option to load a natbib package. (\usepackage[optionalrh,natbib]{spr-sola-addons})
    * 2008.04.23
          o journal's style - modified the footer
          o spr-mp-sola.bst
          o spr-mp-sola-cnd.bst
    * 2007.10.09
          o template added, modifications to spr-sola-addons and example file
    * 2007.08.01 spr-mp-sola
    * 2007.07.10 spr-mp-sola
    * 2007.04.16 spr-sola-addons
          o minor amendmends
    * 2007.03.23 sola-support.zip
          o SolarPhysics.zip, url.sty files added to the package
    * 2007.03.23 spr-sola-addons, template
          o minor amendmends: running author/title, email
    * 2007.02.28 template.tex
          o included into the distribution
    * 2007.02.23 spr-astr-addons
          o sectioning counter format amended
          o urlstyle introduced (sans serif)

