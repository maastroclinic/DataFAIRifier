<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:param name="hl7CharacterSet"/>

  <xsl:template name="attr">
    <xsl:param name="tag"/>
    <xsl:param name="vr"/>
    <xsl:param name="val"/>
    <xsl:if test="$val">
      <DicomAttribute tag="{$tag}" vr="{$vr}">
        <xsl:if test="$val != '&quot;&quot;'">
          <Value number="1">
            <xsl:value-of select="$val"/>
          </Value>
        </xsl:if>
      </DicomAttribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="sex">
    <xsl:param name="val"/>
    <xsl:if test="$val">
      <xsl:choose>
        <xsl:when test="$val = 'F' or $val = 'M' or $val = 'O'">
          <xsl:value-of select="$val"/>
        </xsl:when>
        <xsl:when test="$val = 'A' or $val = 'N'">O</xsl:when>
        <xsl:otherwise>&quot;&quot;</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="pnComp">
    <xsl:param name="name"/>
    <xsl:param name="val"/>
    <xsl:if test="$val and $val != '&quot;&quot;'">
      <xsl:element name="{$name}">
        <xsl:value-of select="$val"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="concat">
    <xsl:param name="val1"/>
    <xsl:param name="val2"/>
    <xsl:choose>
      <xsl:when test="not ($val1 and $val1 != '&quot;&quot;')">
        <xsl:value-of select="$val2"/>
      </xsl:when>
      <xsl:when test="not ($val2 and $val2 != '&quot;&quot;')">
        <xsl:value-of select="$val1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($val1,' ',$val2)"/>
      </xsl:otherwise>
    </xsl:choose>
   </xsl:template>

  <xsl:template name="pnAttr">
    <xsl:param name="tag"/>
    <xsl:param name="val"/>
    <xsl:param name="fn"/>
    <xsl:param name="gn"/>
    <xsl:param name="mn"/>
    <xsl:param name="np"/>
    <xsl:param name="ns"/>
    <xsl:param name="deg"/>
    <xsl:if test="$val">
      <DicomAttribute tag="{$tag}" vr="PN">
        <xsl:if test="$val != '&quot;&quot;'">
          <PersonName number="1">
            <Alphabetic>
              <xsl:call-template name="pnComp">
                <xsl:with-param name="name">FamilyName</xsl:with-param>
                <xsl:with-param name="val" select="$fn"/>
              </xsl:call-template>
              <xsl:call-template name="pnComp">
                <xsl:with-param name="name">GivenName</xsl:with-param>
                <xsl:with-param name="val" select="$gn"/>
              </xsl:call-template>
              <xsl:call-template name="pnComp">
                <xsl:with-param name="name">MiddleName</xsl:with-param>
                <xsl:with-param name="val" select="$mn"/>
              </xsl:call-template>
              <xsl:call-template name="pnComp">
                <xsl:with-param name="name">NamePrefix</xsl:with-param>
                <xsl:with-param name="val" select="$np"/>
              </xsl:call-template>
              <xsl:call-template name="pnComp">
                <xsl:with-param name="name">NameSuffix</xsl:with-param>
                <xsl:with-param name="val">
                  <xsl:call-template name="concat">
                    <xsl:with-param name="val1" select="$ns"/>
                    <xsl:with-param name="val2" select="$deg"/>
                  </xsl:call-template>
                </xsl:with-param>
              </xsl:call-template>
            </Alphabetic>
          </PersonName>
        </xsl:if>
      </DicomAttribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="vetPID2attr">
    <xsl:param name="chip"/>
    <xsl:param name="tattoo"/>
    <xsl:param name="neutered"/>
    <xsl:param name="owner"/>
    <xsl:param name="species"/>
    <xsl:param name="breed"/>
    <xsl:if test="$chip/text() or $tattoo/text()">
      <DicomAttribute tag="00101002" vr="SQ">
        <xsl:if test="$chip/text()">
          <xsl:call-template name="vet-otherPIDs">
            <xsl:with-param name="itemNo" select="'1'"/>
            <xsl:with-param name="pid" select="$chip/text()"/>
            <xsl:with-param name="pid-issuer" select="$chip/component[3]"/>
            <xsl:with-param name="default-pid-issuer" select="'CHIP'"/>
            <xsl:with-param name="pid-type" select="'RFID'"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="$tattoo/text()">
          <xsl:call-template name="vet-otherPIDs">
            <xsl:with-param name="itemNo">
              <xsl:choose>
                <xsl:when test="$chip/text()">
                  <xsl:value-of select="'2'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="'1'"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="pid" select="$tattoo/text()"/>
            <xsl:with-param name="pid-issuer" select="$tattoo/component[3]"/>
            <xsl:with-param name="default-pid-issuer" select="'TATTOO'"/>
            <xsl:with-param name="pid-type" select="'BARCODE'"/>
          </xsl:call-template>
        </xsl:if>
      </DicomAttribute>
    </xsl:if>
    <xsl:if test="$neutered">
      <xsl:call-template name="attr">
        <xsl:with-param name="tag" select="'00102203'"/>
        <xsl:with-param name="vr" select="'CS'"/>
        <xsl:with-param name="val">
          <xsl:choose>
            <xsl:when test="$neutered = 'Y'">ALTERED</xsl:when>
            <xsl:when test="$neutered = 'N'">UNALTERED</xsl:when>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$species/text()">
      <xsl:call-template name="vet-codedEntry">
        <xsl:with-param name="descTag" select="'00102201'"/>
        <xsl:with-param name="seqTag" select="'00102202'"/>
        <xsl:with-param name="codedEntry" select="$species"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$breed/text()">
      <xsl:call-template name="vet-codedEntry">
        <xsl:with-param name="descTag" select="'00102292'"/>
        <xsl:with-param name="seqTag" select="'00102293'"/>
        <xsl:with-param name="codedEntry" select="$breed"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$owner/text()">
      <xsl:call-template name="xpn2pnAttr">
        <xsl:with-param name="tag" select="'00102297'"/>
        <xsl:with-param name="xpn" select="$owner"/>
      </xsl:call-template>
      <xsl:call-template name="attr">
        <xsl:with-param name="tag" select="'00102298'"/>
        <xsl:with-param name="vr" select="'CS'"/>
        <xsl:with-param name="val" select="'OWNER'"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="vet-codedEntry">
    <xsl:param name="descTag"/>
    <xsl:param name="seqTag"/>
    <xsl:param name="codedEntry"/>
    <xsl:call-template name="attr">
      <xsl:with-param name="tag" select="$descTag"/>
      <xsl:with-param name="vr" select="'LO'"/>
      <xsl:with-param name="val" select="$codedEntry/component[1]"/>
    </xsl:call-template>
    <xsl:call-template name="vet-codeItem">
      <xsl:with-param name="sqtag" select="$seqTag"/>
      <xsl:with-param name="code" select="$codedEntry/text()"/>
      <xsl:with-param name="meaning" select="$codedEntry/component[1]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="cx2pidAttrs">
    <xsl:param name="cx"/>
    <DicomAttribute tag="00100020" vr="LO">
      <Value number="1">
        <xsl:value-of select="$cx/text()"/>
      </Value>
    </DicomAttribute>
    <xsl:variable name="hd" select="$cx/component[3]" />
    <xsl:if test="$hd">
      <DicomAttribute tag="00100021" vr="LO">
        <Value number="1">
          <xsl:value-of select="$hd/text()"/>
        </Value>
      </DicomAttribute>
      <xsl:if test="$hd/subcomponent[2]">
        <DicomAttribute tag="00100024" vr="SQ">
          <Item number="1">
            <DicomAttribute tag="00400032" vr="UT">
              <Value number="1">
                <xsl:value-of select="$hd/subcomponent[1]"/>
              </Value>
            </DicomAttribute>
            <DicomAttribute tag="00400033" vr="CS">
              <Value number="1">
                <xsl:value-of select="$hd/subcomponent[2]"/>
              </Value>
            </DicomAttribute>
          </Item>
        </DicomAttribute>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="xpn2pnAttr">
    <xsl:param name="tag"/>
    <xsl:param name="xpn"/>
    <xsl:param name="xpn25" select="$xpn/component"/>
    <xsl:call-template name="pnAttr">
      <xsl:with-param name="tag" select="$tag"/>
      <xsl:with-param name="val" select="string($xpn/text())"/>
      <xsl:with-param name="fn" select="string($xpn/text())"/>
      <xsl:with-param name="gn" select="string($xpn25[1]/text())"/>
      <xsl:with-param name="mn" select="string($xpn25[2]/text())"/>
      <xsl:with-param name="ns" select="string($xpn25[3]/text())"/>
      <xsl:with-param name="np" select="string($xpn25[4]/text())"/>
      <xsl:with-param name="deg" select="string($xpn25[5]/text())"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="cn2pnAttr">
    <xsl:param name="tag"/>
    <xsl:param name="cn"/>
    <xsl:param name="cn26" select="$cn/component"/>
    <xsl:call-template name="pnAttr">
      <xsl:with-param name="tag" select="$tag"/>
      <xsl:with-param name="val" select="string($cn/text())"/>
      <xsl:with-param name="fn" select="string($cn26[1]/text())"/>
      <xsl:with-param name="gn" select="string($cn26[2]/text())"/>
      <xsl:with-param name="mn" select="string($cn26[3]/text())"/>
      <xsl:with-param name="ns" select="string($cn26[4]/text())"/>
      <xsl:with-param name="np" select="string($cn26[5]/text())"/>
      <xsl:with-param name="deg" select="string($cn26[6]/text())"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="codeItem">
    <xsl:param name="sqtag"/>
    <xsl:param name="code"/>
    <xsl:param name="scheme"/>
    <xsl:param name="meaning"/>
    <xsl:if test="$code">
      <DicomAttribute tag="{$sqtag}" vr="SQ">
        <Item number="1">
          <!-- Code Value -->
          <DicomAttribute tag="00080100" vr="SH">
            <Value number="1">
              <xsl:value-of select="$code"/>
            </Value>
          </DicomAttribute>
          <!-- Coding Scheme Designator -->
          <DicomAttribute tag="00080102" vr="SH">
            <Value number="1">
              <xsl:value-of select="$scheme"/>
            </Value>
          </DicomAttribute>
          <!-- Code Meaning -->
          <DicomAttribute tag="00080104" vr="LO">
            <Value number="1">
              <xsl:value-of select="$meaning"/>
            </Value>
          </DicomAttribute>
        </Item>
      </DicomAttribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="vet-codeItem">
    <xsl:param name="sqtag"/>
    <xsl:param name="code"/>
    <xsl:param name="meaning"/>
    <xsl:if test="$code">
      <DicomAttribute tag="{$sqtag}" vr="SQ">
        <Item number="1">
          <!-- Code Value -->
          <DicomAttribute tag="00080100" vr="SH">
            <Value number="1">
              <xsl:value-of select="$code"/>
            </Value>
          </DicomAttribute>
          <!-- Code Meaning -->
          <DicomAttribute tag="00080104" vr="LO">
            <Value number="1">
              <xsl:value-of select="$meaning"/>
            </Value>
          </DicomAttribute>
        </Item>
      </DicomAttribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="vet-otherPIDs">
    <xsl:param name="itemNo"/>
    <xsl:param name="pid"/>
    <xsl:param name="pid-issuer"/>
    <xsl:param name="default-pid-issuer"/>
    <xsl:param name="pid-type"/>
    <xsl:if test="$pid">
      <Item number="{$itemNo}">
        <!-- Patient ID -->
        <DicomAttribute tag="00100020" vr="LO">
          <Value number="1">
            <xsl:value-of select="$pid"/>
          </Value>
        </DicomAttribute>
        <!-- Issuer of Patient ID -->
        <DicomAttribute tag="00100021" vr="LO">
          <Value number="1">
              <xsl:choose>
                <xsl:when test="$pid-issuer/text()">
                  <xsl:value-of select="$pid-issuer/text()"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$default-pid-issuer"/>
                </xsl:otherwise>
              </xsl:choose>
          </Value>
        </DicomAttribute>
        <!-- Type of Patient ID -->
        <DicomAttribute tag="00100022" vr="CS">
          <Value number="1">
            <xsl:value-of select="$pid-type"/>
          </Value>
        </DicomAttribute>
      </Item>
    </xsl:if>
  </xsl:template>

  <xsl:template match="PID">
    <!-- Patient Name -->
    <xsl:call-template name="xpn2pnAttr">
      <xsl:with-param name="tag" select="'00100010'"/>
      <xsl:with-param name="xpn" select="field[5]"/>
    </xsl:call-template>
    <!-- Patient ID -->
    <xsl:call-template name="cx2pidAttrs">
      <xsl:with-param name="cx" select="field[3]"/>
    </xsl:call-template>
    <!-- Patient Birth Date -->
    <xsl:call-template name="attr">
      <xsl:with-param name="tag" select="'00100030'"/>
      <xsl:with-param name="vr" select="'DA'"/>
      <xsl:with-param name="val" select="substring(field[7],1,8)"/>
    </xsl:call-template>
    <!-- Patient Sex -->
    <xsl:call-template name="attr">
      <xsl:with-param name="tag" select="'00100040'"/>
      <xsl:with-param name="vr" select="'CS'"/>
      <xsl:with-param name="val">
        <xsl:call-template name="sex">
          <xsl:with-param name="val" select="field[8]/text()"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <!-- Patient's Mother's Birth Name -->
    <xsl:call-template name="xpn2pnAttr">
      <xsl:with-param name="tag" select="'00101060'"/>
      <xsl:with-param name="xpn" select="field[6]"/>
    </xsl:call-template>
    <!-- Veterinary Patient -->
    <xsl:call-template name="vetPID2attr">
      <xsl:with-param name="chip" select="field[2]" />
      <xsl:with-param name="tattoo" select="field[4]" />
      <xsl:with-param name="neutered" select="field[8]/component/text()"/>
      <xsl:with-param name="owner" select="field[9]"/>
      <xsl:with-param name="species" select="field[35]"/>
      <xsl:with-param name="breed" select="field[36]"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="MRG">
    <!-- Modified Attributes Sequence -->
    <DicomAttribute tag="04000550" vr="SQ">
      <Item number="1">
        <!-- Patient Name -->
        <xsl:call-template name="xpn2pnAttr">
            <xsl:with-param name="tag" select="'00100010'"/>
            <xsl:with-param name="xpn" select="field[7]"/>
        </xsl:call-template>
        <!-- Patient ID -->
        <xsl:call-template name="cx2pidAttrs">
            <xsl:with-param name="cx" select="field[1]"/>
        </xsl:call-template>
      </Item>
    </DicomAttribute>
  </xsl:template>
  <xsl:template name="ei2attr">
    <xsl:param name="tag"/>
    <xsl:param name="ei"/>
    <DicomAttribute tag="{$tag}" vr="LO">
      <Value number="1">
      <xsl:value-of select="string($ei/text())"/>
      <xsl:text>^</xsl:text>
      <xsl:value-of select="string($ei/component[1]/text())"/>
      </Value>
    </DicomAttribute>
  </xsl:template>
  <xsl:template name="attrDATM">
    <xsl:param name="datag"/>
    <xsl:param name="tmtag"/>
    <xsl:param name="val"/>
    <xsl:variable name="str" select="normalize-space($val)" />
    <xsl:if test="$str">
      <DicomAttribute tag="{$datag}" vr="DA">
        <Value number="1">
        <xsl:if test="$str != '&quot;&quot;'">
          <xsl:value-of select="substring($str,1,8)" />
        </xsl:if>
        </Value>
      </DicomAttribute>
      <DicomAttribute tag="{$tmtag}" vr="TM">
        <Value number="1">
        <xsl:if test="$str != '&quot;&quot;'">
          <xsl:variable name="tm" select="substring($str,9)"/>
          <!-- Skip Time Zone-->
          <xsl:variable name="tm_plus" select="substring-before($tm,'+')"/>
          <xsl:variable name="tm_minus" select="substring-before($tm,'-')"/>
          <xsl:choose>
            <xsl:when test="$tm_plus">
              <xsl:value-of select="$tm_plus"/>
            </xsl:when>
            <xsl:when test="$tm_minus">
              <xsl:value-of select="$tm_minus"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$tm"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        </Value>
      </DicomAttribute>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
