<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Yale EAD @id and <head> value Params

This file is included via xsl:include in multiple stylesheets.  

Created:     2008-07-23
Updated:    2012-01-06
Contact:      michael.rush@yale.edu, findingaids.feedback@yale.edu
URL:            http://www.library.yale.edu/facc/xsl/include/yale.ead2002.id_head_values.xsl

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:y="http://www.library.yale.edu/facc/schemas/yale.ead2002" xmlns:marc="http://www.loc.gov/MARC21/slim" 
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="urn:isbn:1-931666-22-9" exclude-result-prefixes="xsl ead y marc xlink xsi" version="1.0">
    
    <!-- ********************* SECTION HEADS and LABELS *********************** -->
    
    <!-- ********************* Titlepage  *********************** -->
    <xsl:param name="original_date_label">Created: </xsl:param>
    <xsl:param name="ead_date_label">Encoded: </xsl:param>
    <xsl:param name="copyright_date_label">Copyright © </xsl:param>
    <xsl:param name="revised_date_label">Revised: </xsl:param>
    
    <!-- ********************* Table of Contents  *********************** -->
    <xsl:param name="tableOfContents_head">Table of Contents</xsl:param>
    
    <!-- ********************* Overview  *********************** -->
    <xsl:param name="aeonPagingInstructions_head">Paging Instructions</xsl:param>
    <xsl:param name="did_head">Overview</xsl:param>
    <xsl:param name="unitid_label">Call Number:</xsl:param>
    <xsl:param name="origination_label">Creator:</xsl:param>
    <xsl:param name="unittitle_label">Title:</xsl:param>
    <xsl:param name="unitdate_label_inclusive">Dates:</xsl:param>
    <xsl:param name="unitdate_label_bulk">Bulk Dates:</xsl:param>
    <xsl:param name="physdesc_label">Physical Description:</xsl:param>
    <xsl:param name="langmaterial_label">Language(s):</xsl:param>
    <xsl:param name="abstract_label">Summary:</xsl:param>
    <xsl:param name="bioghist_545_label">Biographical/Historical Overview:</xsl:param>
    <xsl:param name="bioghist_biogOver_label">Biographical Overview:</xsl:param>
    <xsl:param name="bioghist_orgOver_label">Historical Overview:</xsl:param>
    <xsl:param name="physloc_label">Physical Location:</xsl:param>
    <xsl:param name="materialspec_label">Material Specification:</xsl:param>
    <xsl:param name="note_label">Note:</xsl:param>
    <xsl:param name="repository_label">Repository:</xsl:param>
    <xsl:param name="catalog_record_label">Catalog Record:</xsl:param>
    <xsl:param name="dl_search_label">Digital Images:</xsl:param>
    <xsl:param name="faHandle_link_label">Finding Aid Link:</xsl:param>
    <xsl:param name="faViewSearch_label">View/Search:</xsl:param>
    <xsl:param name="requestForm_link_label">Request Materials:</xsl:param>
    <xsl:param name="yrg_label">Forms Part Of:</xsl:param>
    <xsl:param name="generalnote_label">General Note:</xsl:param>
    <xsl:param name="localnote_label">Local Note:</xsl:param>
    <xsl:param name="acknowledgement_label">Acknowledgements:</xsl:param>
    
    <!-- ********************* Administrative Information  *********************** -->
    <xsl:param name="admininfo_head">Administrative Information</xsl:param>
    <xsl:param name="provenance_head">Provenance</xsl:param>
    <xsl:param name="acqinfo_head">Acquisition Information</xsl:param>
    <xsl:param name="custodhist_head">Custodial History</xsl:param>
    <xsl:param name="accessrestrict_head">Information about Access</xsl:param>
    <xsl:param name="userestrict_head">Ownership &amp; Copyright</xsl:param>
    <xsl:param name="prefercite_head">Cite As</xsl:param>
    <xsl:param name="processinfo_head">Processing Notes</xsl:param>
    <xsl:param name="relatedmaterial_head">Associated Materials</xsl:param>
    <xsl:param name="separatedmaterial_head">Separated Materials</xsl:param>
    <xsl:param name="altformavail_head">Alternative Formats</xsl:param>
    <xsl:param name="accruals_head">Accruals</xsl:param>
    <xsl:param name="appraisal_head">Appraisal</xsl:param>
    <xsl:param name="originalsloc_head">Location of Originals</xsl:param>
    <xsl:param name="otherfindaid_head">Other Finding Aids</xsl:param>
    <xsl:param name="phystech_head">Physical Characteristics / Technical Requirements</xsl:param>
    <xsl:param name="fileplan_head">File Plan</xsl:param>
    <xsl:param name="bibliography_head">Bibliography</xsl:param>
    
    <!-- ********************* Archdesc elements  *********************** -->
    <xsl:param name="bioghist_head">Biographical/Historical Sketch</xsl:param>
    <xsl:param name="biogFull_head">Biographical Sketch</xsl:param>
    <xsl:param name="orgFull_head">Organizational History</xsl:param>
    <xsl:param name="chronlist_head">Chronological History</xsl:param>
    <xsl:param name="scopecontent_head">Description of the Collection</xsl:param>
    <xsl:param name="arrangement_head">Arrangement</xsl:param>
    <xsl:param name="controlaccess_head">Access Terms</xsl:param>
    <xsl:param name="dsc_head">Collection Contents</xsl:param>
    <xsl:param name="index_head">Index</xsl:param>
    <xsl:param name="odd_head">Appendix</xsl:param>
    
    <!-- ********************* Physdesc elements  *********************** -->
    <xsl:param name="extent_label">Extent: </xsl:param>
    <xsl:param name="dimensions_label">Dimensions: </xsl:param>
    <xsl:param name="physfacet_label_presCondition">Preservation status: </xsl:param>
    
    <!-- ********************* END SECTION HEADS and LABELS *********************** -->
    
    
    <!-- ********************* SECTION IDS *********************** -->
    <!-- default to these if @id is not present -->
    
    <!-- ********************* Table of Contents  *********************** -->
    <xsl:param name="tableOfContents_id">tocID</xsl:param>
    
    <!-- ********************* Overview  *********************** -->
    <xsl:param name="aeonPagingInstructions_id">aeon</xsl:param>
    <xsl:param name="did_id">did</xsl:param>
    
    <!-- ********************* Administrative Information  *********************** -->
    <xsl:param name="admininfo_id">ai</xsl:param>
    <xsl:param name="provenance_id">prov</xsl:param>
    <xsl:param name="acqinfo_id">acq</xsl:param>
    <xsl:param name="custodhist_id">cust</xsl:param>
    <xsl:param name="accessrestrict_id">arest</xsl:param>
    <xsl:param name="userestrict_id">urest</xsl:param>
    <xsl:param name="prefercite_id">cite</xsl:param>
    <xsl:param name="processinfo_id">pi</xsl:param>
    <xsl:param name="relatedmaterial_id">relma</xsl:param>
    <xsl:param name="separatedmaterial_id">sm</xsl:param>
    <xsl:param name="altformavail_id">altfa</xsl:param>
    <xsl:param name="accruals_id">accr</xsl:param>
    <xsl:param name="appraisal_id">appr</xsl:param>
    <xsl:param name="originalsloc_id">orloc</xsl:param>
    <xsl:param name="otherfindaid_id">ofa</xsl:param>
    <xsl:param name="phystech_id">pt</xsl:param>
    <xsl:param name="fileplan_id">fp</xsl:param>
    <xsl:param name="bibliography_id">bib</xsl:param>
    
    <!-- ********************* Archdesc elements  *********************** -->
    <xsl:param name="bioghist_id">bh</xsl:param>
    <xsl:param name="block_bioghist_id">bbh</xsl:param>
    <xsl:param name="biogFull_id">BiogFull</xsl:param>
    <xsl:param name="orgFull_id">orgID</xsl:param>
    <xsl:param name="scopecontent_id">sc</xsl:param>
    <xsl:param name="arrangement_id">arr</xsl:param>
    <xsl:param name="controlaccess_id">ca</xsl:param>
    <xsl:param name="block_controlaccess_id">bca</xsl:param>
    <xsl:param name="dsc_id">dsc</xsl:param>
    <xsl:param name="odd_id">odd</xsl:param>
    <xsl:param name="block_odd_id">bodd</xsl:param>
    <xsl:param name="index_id">ind</xsl:param>
    
    <!-- ********************* END SECTION IDS *********************** -->
    

</xsl:stylesheet>
