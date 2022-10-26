<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright 2022 FIZ Karlsruhe - Leibniz-Institut fuer Informationsinfrastruktur GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" version="1.0">

  <xsl:output method="xml" indent="yes"/>

  <!-- Used in xsl files for later versions to apply the corresponding layout per condition -->
  <xsl:template match="*">
    <xsl:for-each select="namespace::*">
      <namespace><xsl:value-of select="local-name()"/>:<xsl:value-of select="."/></namespace>
      <xsl:if test="local-name() = ''">
        <xsl:value-of select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="/">
    <!-- Check for radar version and apply the corresponding template -->
    <xsl:variable name="namespace">
      <xsl:apply-templates select="*"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($namespace, '/v09/')">
        <xsl:call-template name="radar-v09"/>
      </xsl:when>
      <xsl:when test="contains($namespace, '/v08/')">
        <xsl:call-template name="radar-v08"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="radar"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="radar-v09">
    <oai_dc:dc xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
               xmlns:dc="http://purl.org/dc/elements/1.1/"
               xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ https://www.openarchives.org/OAI/2.0/oai_dc.xsd http://purl.org/dc/elements/1.1/ https://www.radar-service.eu/schemas/dc.xsd">
      <dc:identifier>
        <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='identifier']"/>
      </dc:identifier>
      <dc:identifier>
        <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='identifier']/@identifierType"/>
      </dc:identifier>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='creators']/*[local-name()='creator']">
        <dc:creator>
          <xsl:value-of select="*[local-name()='creatorName']"/>
        </dc:creator>
        <xsl:if test="*[local-name()='nameIdentifier']">
          <dc:identifier>
            <xsl:value-of select="*[local-name()='nameIdentifier']"/>
          </dc:identifier>
        </xsl:if>
      </xsl:for-each>
      <dc:title>
        <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='title']"/>
      </dc:title>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='publishers']">
        <dc:publisher>
          <xsl:value-of select="*[local-name()='publisher']"/>
        </dc:publisher>
      </xsl:for-each>
      <dc:date>
        <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='publicationYear']"/>
      </dc:date>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='subjectAreas']/*[local-name()='subjectArea']/*">
        <dc:subject>
          <xsl:value-of select="."/>
        </dc:subject>
      </xsl:for-each>
      <dc:type>
        <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='resource']"/>
      </dc:type>
      <dc:type>
        <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='resource']/@resourceType"/>
      </dc:type>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='dataSources']/*[local-name()='dataSource']">
        <dc:source>
          <xsl:value-of select="."/>
        </dc:source>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='dataSources']/*[local-name()='dataSource']/@dataSourceDetail">
        <dc:source>
          <xsl:value-of select="."/>
        </dc:source>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='rights']/*">
        <dc:rights>
          <xsl:value-of select="."/>
        </dc:rights>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='rightsHolders']/*[local-name()='rightsHolder']">
        <dc:rights>
          <xsl:value-of select="."/>
        </dc:rights>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='contributors']/*[local-name()='contributor']">
        <dc:contributor>
          <xsl:value-of select="*[local-name()='contributorName']"/>
        </dc:contributor>
        <xsl:if test="*[local-name()='nameIdentifier']">
          <dc:identifier>
            <xsl:value-of select="*[local-name()='nameIdentifier']"/>
          </dc:identifier>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='descriptions']/*[local-name()='description']">
        <dc:description>
          <xsl:value-of select="."/>
        </dc:description>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='keywords']/*[local-name()='keyword']">
        <dc:subject>
          <xsl:value-of select="."/>
        </dc:subject>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='contributors']/*[local-name()='contributor']">
        <dc:contributor>
          <xsl:value-of select="*[local-name()='contributorName']"/>
        </dc:contributor>
      </xsl:for-each>
      <dc:language>
        <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='language']"/>
      </dc:language>
      <xsl:if test="*[local-name()='radarDataset']/*[local-name()='alternateIdentifiers']/*[local-name()='alternateIdentifier']">
        <dc:identifier>
          <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='alternateIdentifiers']/*[local-name()='alternateIdentifier']"/>
        </dc:identifier>
        <dc:identifier>
          <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='alternateIdentifiers']/*[local-name()='alternateIdentifier']/@alternateIdentifierType"/>
        </dc:identifier>
      </xsl:if>
      <xsl:if test="*[local-name()='radarDataset']/*[local-name()='relatedIdentifiers']/*[local-name()='relatedIdentifier']">
        <dc:relation>
          <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='relatedIdentifiers']/*[local-name()='relatedIdentifier']"/>
        </dc:relation>
        <dc:identifier>
          <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='relatedIdentifiers']/*[local-name()='relatedIdentifier']"/>
        </dc:identifier>
        <dc:relation>
          <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='relatedIdentifiers']/*[local-name()='relatedIdentifier']/@relatedIdentifierType"/>
        </dc:relation>
        <dc:identifier>
          <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='relatedIdentifiers']/*[local-name()='relatedIdentifier']/@relatedIdentifierType"/>
        </dc:identifier>
      </xsl:if>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='geoLocations']/*[local-name()='geoLocation']">
        <dc:coverage>
          <xsl:choose>
            <xsl:when test="*[local-name()='geoLocationCountry'] and *[local-name()='geoLocationRegion']">
              <xsl:value-of select="*[local-name()='geoLocationCountry']"/>
              <xsl:text> (</xsl:text>
              <xsl:value-of select="*[local-name()='geoLocationRegion']"/>
              <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:when test="*[local-name()='geoLocationCountry']">
              <xsl:value-of select="*[local-name()='geoLocationCountry']"/>
            </xsl:when>
            <xsl:when test="*[local-name()='geoLocationRegion']">
              <xsl:value-of select="*[local-name()='geoLocationRegion']"/>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="*[local-name()='geoLocationPoint'] or *[local-name()='geoLocationBox']">
            <xsl:text>: </xsl:text>
            <xsl:choose>
              <xsl:when test="*[local-name()='geoLocationBox']">
                <xsl:text>Lat/Long/Datum </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationBox']/*[local-name()='southWestPoint']/*[local-name()='latitude']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationBox']/*[local-name()='southWestPoint']/*[local-name()='longitude']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationBox']/*[local-name()='northEastPoint']/*[local-name()='latitude']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationBox']/*[local-name()='northEastPoint']/*[local-name()='longitude']"/>
              </xsl:when>
              <xsl:when test="*[local-name()='geoLocationPoint']">
                <xsl:text>Lat/Long/Datum </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationPoint']/*[local-name()='latitude']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationPoint']/*[local-name()='longitude']"/>
              </xsl:when>
            </xsl:choose>
            <xsl:text> (WGS 84)</xsl:text>
          </xsl:if>
        </dc:coverage>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='fundingReferences']/*[local-name()='fundingReference']">
        <xsl:if test="*[local-name()='funderIdentifier']">
          <dc:identifier>
            <xsl:value-of select="*[local-name()='funderIdentifier']"/>
          </dc:identifier>
        </xsl:if>
      </xsl:for-each>
      <dc:format>application/zip</dc:format>
    </oai_dc:dc>
  </xsl:template>

  <xsl:template name="radar-v08">
    <oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ https://www.openarchives.org/OAI/2.0/oai_dc.xsd http://purl.org/dc/elements/1.1/ https://www.radar-service.eu/schemas/dc.xsd" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
      <dc:identifier>
        <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='identifier']"/>
      </dc:identifier>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='creators']/*[local-name()='creator']">
        <dc:creator>
          <xsl:value-of select="*[local-name()='creatorName']"/>
        </dc:creator>
      </xsl:for-each>
      <dc:title>
        <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='title']"/>
      </dc:title>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='publishers']">
        <dc:publisher>
          <xsl:value-of select="*[local-name()='publisher']"/>
        </dc:publisher>
      </xsl:for-each>
      <dc:date>
        <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='publicationYear']"/>
      </dc:date>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='subjectAreas']/*[local-name()='subjectArea']/*">
        <dc:subject>
          <xsl:value-of select="."/>
        </dc:subject>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='rights']/*">
        <dc:rights>
          <xsl:value-of select="."/>
        </dc:rights>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='descriptions']/*[local-name()='description']">
        <dc:description>
          <xsl:value-of select="."/>
        </dc:description>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='keywords']/*[local-name()='keyword']">
        <dc:subject>
          <xsl:value-of select="."/>
        </dc:subject>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='contributors']">
        <dc:contributor>
          <xsl:value-of select="*[local-name()='contributor']"/>
        </dc:contributor>
      </xsl:for-each>
      <dc:language>
        <xsl:value-of select="*[local-name()='radarDataset']/*[local-name()='language']"/>
      </dc:language>
      <xsl:for-each select="*[local-name()='radarDataset']/*[local-name()='geoLocations']/*[local-name()='geoLocation']">
        <dc:coverage>
          <xsl:choose>
            <xsl:when test="*[local-name()='geoLocationCountry'] and *[local-name()='geoLocationRegion']">
              <xsl:value-of select="*[local-name()='geoLocationCountry']"/>
              <xsl:text> (</xsl:text>
              <xsl:value-of select="*[local-name()='geoLocationRegion']"/>
              <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:when test="*[local-name()='geoLocationCountry']">
              <xsl:value-of select="*[local-name()='geoLocationCountry']"/>
            </xsl:when>
            <xsl:when test="*[local-name()='geoLocationRegion']">
              <xsl:value-of select="*[local-name()='geoLocationRegion']"/>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="*[local-name()='geoLocationPoint'] or *[local-name()='geoLocationBox']">
            <xsl:text>: </xsl:text>
            <xsl:choose>
              <xsl:when test="*[local-name()='geoLocationBox']">
                <xsl:text>Lat/Long/Datum </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationBox']/*[local-name()='southWestPoint']/*[local-name()='latitude']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationBox']/*[local-name()='southWestPoint']/*[local-name()='longitude']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationBox']/*[local-name()='northEastPoint']/*[local-name()='latitude']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationBox']/*[local-name()='northEastPoint']/*[local-name()='longitude']"/>
              </xsl:when>
              <xsl:when test="*[local-name()='geoLocationPoint']">
                <xsl:text>Lat/Long/Datum </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationPoint']/*[local-name()='latitude']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationPoint']/*[local-name()='longitude']"/>
              </xsl:when>
            </xsl:choose>
            <xsl:text> (WGS 84)</xsl:text>
          </xsl:if>
        </dc:coverage>
      </xsl:for-each>
    </oai_dc:dc>
  </xsl:template>

  <xsl:template name="radar">
    <oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
      <dc:identifier>
        <xsl:value-of select="*[local-name()='radar']/*[local-name()='identifier']"/>
      </dc:identifier>
      <xsl:for-each select="*[local-name()='radar']/*[local-name()='creators']/*[local-name()='creator']">
        <dc:creator>
          <xsl:value-of select="*[local-name()='creatorName']"/>
        </dc:creator>
      </xsl:for-each>
      <dc:title>
        <xsl:value-of select="*[local-name()='radar']/*[local-name()='title']"/>
      </dc:title>
      <xsl:for-each select="*[local-name()='radar']/*[local-name()='publishers']">
        <dc:publisher>
          <xsl:value-of select="*[local-name()='publisher']"/>
        </dc:publisher>
      </xsl:for-each>
      <dc:date>
        <xsl:value-of select="*[local-name()='radar']/*[local-name()='publicationYear']"/>
      </dc:date>
      <xsl:for-each select="*[local-name()='radar']/*[local-name()='subjectAreas']">
        <xsl:for-each select="*[local-name()='subjectArea']/*">
          <dc:subject>
            <xsl:value-of select="."/>
          </dc:subject>
        </xsl:for-each>
      </xsl:for-each>
      <dc:rights>
        <xsl:value-of select="*[local-name()='radar']/*[local-name()='rights']"/>
      </dc:rights>
      <xsl:for-each select="*[local-name()='radar']/*[local-name()='descriptions']">
        <dc:description>
          <xsl:value-of select="*[local-name()='description']"/>
        </dc:description>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radar']/*[local-name()='keywords']">
        <dc:subject>
          <xsl:value-of select="*[local-name()='keyword']"/>
        </dc:subject>
      </xsl:for-each>
      <xsl:for-each select="*[local-name()='radar']/*[local-name()='contributors']">
        <dc:contributor>
          <xsl:value-of select="*[local-name()='contributor']"/>
        </dc:contributor>
      </xsl:for-each>
      <dc:language>
        <xsl:value-of select="*[local-name()='radar']/*[local-name()='language']"/>
      </dc:language>
      <xsl:for-each select="*[local-name()='radar']/*[local-name()='geoLocations']/*[local-name()='geoLocation']">
        <dc:coverage>
          <xsl:choose>
            <xsl:when test="*[local-name()='geoLocationCountry'] and *[local-name()='geoLocationRegion']">
              <xsl:value-of select="*[local-name()='geoLocationCountry']"/>
              <xsl:text> (</xsl:text>
              <xsl:value-of select="*[local-name()='geoLocationRegion']"/>
              <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:when test="*[local-name()='geoLocationCountry']">
              <xsl:value-of select="*[local-name()='geoLocationCountry']"/>
            </xsl:when>
            <xsl:when test="*[local-name()='geoLocationRegion']">
              <xsl:value-of select="*[local-name()='geoLocationRegion']"/>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="*[local-name()='geoLocationPoint'] or *[local-name()='geoLocationBox']">
            <xsl:text>: </xsl:text>
            <xsl:choose>
              <xsl:when test="*[local-name()='geoLocationBox']">
                <xsl:text>Lat/Long/Datum </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationBox']/*[local-name()='southWestPoint']/*[local-name()='latitude']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationBox']/*[local-name()='southWestPoint']/*[local-name()='longitude']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationBox']/*[local-name()='northEastPoint']/*[local-name()='latitude']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationBox']/*[local-name()='northEastPoint']/*[local-name()='longitude']"/>
              </xsl:when>
              <xsl:when test="*[local-name()='geoLocationPoint']">
                <xsl:text>Lat/Long/Datum </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationPoint']/*[local-name()='latitude']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="*[local-name()='geoLocationPoint']/*[local-name()='longitude']"/>
              </xsl:when>
            </xsl:choose>
            <xsl:text> (WGS 84)</xsl:text>
          </xsl:if>
        </dc:coverage>
      </xsl:for-each>
    </oai_dc:dc>
  </xsl:template>

</xsl:stylesheet>