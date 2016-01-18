# encoding: utf-8

module CouponTestHelper
  def block_to_test_it(file)
    begin
      prepare(file)
      yield if block_given?
    ensure
      clean_up(file)
    end
  end

  private
  
  def prepare(file)
    File.open(file, 'w') do |f|
      f.write(xml_coupons)
    end
    `cp #{file} #{Rails.root}/test.xml`
  end
  
  def clean_up(file)
    File.delete(file) if File.exists?(file)
  end
  
  def xml_coupons
    '<?xml version="1.0" encoding="utf-8"?>
    <response>
      <date>2012-01-26</date>
      <time>13:12.17</time>
      <type>data</type>
      <count>10</count>
      <your_uid>brunch</your_uid>
      <your_ip>85.214.105.79</your_ip>
      <coupons>
        <coupon>
          <id>577</id>
          <name>20% Extra-Rabatt auf bereits reduzierte Artikel</name>
          <valid_from>2012-01-19</valid_from>
          <valid_to>2012-01-26</valid_to>
          <favourite>true</favourite>
          <merchant_id>1</merchant_id>
          <categories>
            <category_1>Uhren &amp; Schmuck</category_1>
            <category_2>Mode &amp; Kleidung</category_2>
            <category_3>Aktion: Sale</category_3>
          </categories>
          <coupon_url>http://zumanbieter.de/?mid=779000&amp;id=577</coupon_url>
          <type>rabattcoupons</type>
          <priority>7</priority>
          <coupon_code>F2S5XY</coupon_code>
          <hint><![CDATA[Kein Mindestbestellwert. Gutscheincode bitte als Promotion-Code im Warenkorb eintragen und "einlösen". Nur für bereits reduzierte Ware im Onlineshop gültig. Gilt auch für Bestandskunden. Versandkostenfreie Lieferung.

    ]]></hint>
        </coupon>
        <coupon>
          <id>700</id>
          <name>15% Rabatt</name>
          <valid_from>2012-01-19</valid_from>
          <valid_to>2012-01-26</valid_to>
          <favourite>false</favourite>
          <merchant_id>2</merchant_id>
          <categories>
            <category_1>Möbel &amp; Wohnen</category_1>
            <category_2>Geschenke</category_2>
          </categories>
          <coupon_url>http://zumanbieter.de/?mid=779000&amp;id=700</coupon_url>
          <type>rabattcoupons</type>
          <priority>15</priority>
          <coupon_code>ROSA</coupon_code>
          <hint><![CDATA[Kein Mindestbestellwert. Gutscheincode bei Bestellung eintragen und mit Klick auf "Eingeben" bestätigen. Nur 1 Gutschein pro Bestellung.

    ]]></hint>
        </coupon>
        <coupon>
          <id>2548</id>
          <name>Versandkostenfreie Lieferung bei Minibär</name>
          <valid_from>2012-01-25</valid_from>
          <valid_to>2012-01-26</valid_to>
          <favourite>false</favourite>
          <merchant_id>3</merchant_id>
          <categories>
            <category_1>Versandhäuser</category_1>
            <category_2>Spielzeug</category_2>
            <category_3>Mode &amp; Kleidung</category_3>
            <category_4>Möbel &amp; Wohnen</category_4>
            <category_5>Drogerie</category_5>
            <category_6>Bio &amp; Fair &amp; Öko</category_6>
            <category_7>Baby</category_7>
          </categories>
          <coupon_url>http://zumanbieter.de/?mid=779000&amp;id=2548</coupon_url>
          <type>rabattcoupons</type>
          <priority>71</priority>
          <coupon_code>742 836</coupon_code>
          <hint><![CDATA[Kein Mindestbestellwert. Nur für Minibär. Den Code als "Vorteilsnummer" im Warenkorb eingeben. Abzug erfolgt erst auf der Rechnung.

    ]]></hint>
        </coupon>
        <coupon>
          <id>4109</id>
          <name>Flüge ab 49,- €</name>
          <valid_from>2012-01-25</valid_from>
          <valid_to>2012-01-26</valid_to>
          <favourite>false</favourite>
          <merchant_id>4</merchant_id>
          <categories>
            <category_1>Reisen &amp; Urlaub</category_1>
          </categories>
          <coupon_url>http://zumanbieter.de/?mid=779000&amp;id=4109</coupon_url>
          <type>rabattcoupons</type>
          <priority>1000</priority>
          <coupon_code></coupon_code>
          <hint><![CDATA[Das gewünschte Urlaubsziel heraussuchen und sparen. Reisezeiträume, Ziele und weitere Infos finden Sie auf der Anbieterseite.

    ]]></hint>
        </coupon>
        <coupon>
          <id>1153</id>
          <name>20,- € Gutschein</name>
          <valid_from>2011-08-16</valid_from>
          <valid_to>2012-01-27</valid_to>
          <favourite>false</favourite>
          <merchant_id>5</merchant_id>
          <categories>
            <category_1>Sport</category_1>
            <category_2>Mode &amp; Kleidung</category_2>
          </categories>
          <coupon_url>http://zumanbieter.de/?mid=779000&amp;id=1153</coupon_url>
          <type>rabattcoupons</type>
          <priority>1000</priority>
          <coupon_code>CN1572TW20</coupon_code>
          <hint><![CDATA[Mindestbestellwert 100,- €. Gilt nicht für reduzierte Ware. Gutscheincode bitte im Warenkorb angeben.

    ]]></hint>
        </coupon>
        <coupon>
          <id>1416</id>
          <name>5,- € Gutschein</name>
          <valid_from>2011-05-20</valid_from>
          <valid_to>2012-01-27</valid_to>
          <favourite>false</favourite>
          <merchant_id>6</merchant_id>
          <categories>
            <category_1>Sport</category_1>
            <category_2>Mode &amp; Kleidung</category_2>
          </categories>
          <coupon_url>http://zumanbieter.de/?mid=779000&amp;id=1416</coupon_url>
          <type>rabattcoupons</type>
          <priority>1000</priority>
          <coupon_code>058a4d</coupon_code>
          <hint><![CDATA[Mindestbestellwert 50,- €. Einfach Kundenkonto anlegen und den Gutscheincode bei Ihrer Bestellung einlösen.

    ]]></hint>
        </coupon>
        <coupon>
          <id>128</id>
          <name>Gratis OTTO-Card inkl. 5,- € Guthaben &amp; 3,- € Guthaben für jede Bestellung</name>
          <valid_from>2011-07-05</valid_from>
          <valid_to>2012-01-27</valid_to>
          <favourite>false</favourite>
          <merchant_id>7</merchant_id>
          <categories>
            <category_1>Versandhäuser</category_1>
            <category_2>Uhren &amp; Schmuck</category_2>
            <category_3>Sport</category_3>
            <category_4>Mode &amp; Kleidung</category_4>
            <category_5>Möbel &amp; Wohnen</category_5>
            <category_6>Hochzeit</category_6>
            <category_7>Elektronik</category_7>
            <category_8>Computer</category_8>
            <category_9>Baumarkt</category_9>
          </categories>
          <coupon_url>http://zumanbieter.de/?mid=779000&amp;id=128</coupon_url>
          <type>gratiscoupons_produktproben</type>
          <priority>25</priority>
          <coupon_code></coupon_code>
          <hint><![CDATA[Kein Mindestbestellwert. Kein Gutscheincode notwendig. Einfach die OTTO-Card gratis anfordern (siehe linke Spalte auf der Anbieterseite), um die Vorteile zu sichern. Bitte beachten Sie weitere Informationen auf der Anbieterseite.

    ]]></hint>
        </coupon>
        <coupon>
          <id>549</id>
          <name>20% Extra-Rabatt auf bereits reduzierte Artikel</name>
          <valid_from>2012-01-23</valid_from>
          <valid_to>2012-01-27</valid_to>
          <favourite>true</favourite>
          <merchant_id>8</merchant_id>
          <categories>
            <category_1>Mode &amp; Kleidung</category_1>
            <category_2>Aktion: Sale</category_2>
          </categories>
          <coupon_url>http://zumanbieter.de/?mid=779000&amp;id=549</coupon_url>
          <type>rabattcoupons</type>
          <priority>8</priority>
          <coupon_code>FINALSALE2012</coupon_code>
          <hint><![CDATA[Kein Mindestbestellwert. Gutscheincode bitte bei Bestellung an der Kasse als E-Shop Coupon eingeben. Nur für die bereits reduzierte Artikel gültig.

    ]]></hint>
        </coupon>
        <coupon>
          <id>633</id>
          <name>50,- € Spielguthaben</name>
          <valid_from>2008-09-22</valid_from>
          <valid_to>2012-01-27</valid_to>
          <favourite>false</favourite>
          <merchant_id>9</merchant_id>
          <categories>
            <category_1>Games</category_1>
          </categories>
          <coupon_url>http://zumanbieter.de/?mid=779000&amp;id=633</coupon_url>
          <type>gratiscoupons_produktproben</type>
          <priority>1000</priority>
          <coupon_code></coupon_code>
          <hint><![CDATA[Die Anmeldung ist komplett kostenlos.

    ]]></hint>
        </coupon>
        <coupon>
          <id>194</id>
          <name>Bis zu 50% Rabatt und bis zu 2 Gratis-Geschenke</name>
          <valid_from>2011-11-17</valid_from>
          <valid_to>2012-01-27</valid_to>
          <favourite>false</favourite>
          <merchant_id>10</merchant_id>
          <categories>
            <category_1>Parfüm &amp; Kosmetik</category_1>
            <category_2>Hochzeit</category_2>
            <category_3>Geschenke</category_3>
          </categories>
          <coupon_url>http://zumanbieter.de/?mid=779000&amp;id=194</coupon_url>
          <type>gratiscoupons_produktproben</type>
          <priority>100</priority>
          <coupon_code></coupon_code>
          <hint><![CDATA[Einfach bestellen und Gratisgeschenke auswählen. Diese werden in den Warenkorb gelegt. 

    ]]></hint>
        </coupon>
        <coupon>
          <id>999</id>
          <name>Bis zu 50% Rabatt und bis zu 2 Gratis-Geschenke</name>
          <valid_from>2011-11-17</valid_from>
          <valid_to>2012-01-27</valid_to>
          <favourite>false</favourite>
          <merchant_id>10</merchant_id>
          <categories>
            <category_1>Parfüm &amp; Kosmetik</category_1>
            <category_2>Hochzeit</category_2>
            <category_3>Geschenke</category_3>
          </categories>
          <coupon_url>http://zumanbieter.de/?mid=779000&amp;id=194</coupon_url>
          <type>gratiscoupons_produktproben</type>
          <priority>100</priority>
          <coupon_code></coupon_code>
          <hint><![CDATA[Einfach bestellen und Gratisgeschenke auswählen. Diese werden in den Warenkorb gelegt. 

    ]]></hint>
        </coupon>
      </coupons>
      <merchants>
        <merchant>
          <id>1</id>
          <name>s.Oliver</name>
          <logo>http://www.coupons4u.de/images/mer_logo_437.jpg</logo>
          <description><![CDATA[Als <font color="#C51F32"><b>s.Oliver</b></font> im Jahr 1969 das erste Geschäft aufmachte, hieß das Unternehmen noch Sir Oliver. Erst 1978 nannte es sich in <font color="#C51F32"><b>s.Oliver</b></font> um und ließ sich ein Jahr später als Marke bei dem deutschen Patent- und Markenamt in München eintragen. Mittlerweile gibt es über 2.700 Shops mit mehr als 7.800 Mitarbeitern. Der Großteil befindet sich in Deutschland.

<br><br>

Aber auch der <font color="#C51F32"><b>s.Oliver</b></font>-Onlineshop ist ein Shoppingvergnügen für die gesamte Familie. Es gibt chice Kleidung für SIE und IHN für alle Lebenssituationen. Und eine extra Linie ab Größe 42 - Triangle. Die Kleinen finden unter Junior farbenfrohe und kindgerechte Mode. Alle Artikel erhalten Sie in bester Qualität und zu fairen Preisen.

<br><br>

Kombinieren Sie Ihr neues Outfit gleich mit den passenden Accessoires wie Brillen, Schirme oder sogar dem passenden Duft. Ihnen gefällt die farbenfrohe  Eleganz von <font color="#C51F32"><b>s.Oliver</b></font>? Dann verschönern Sie doch Ihr Zuhause gleich mit - wählen Sie aus Teppichen, Bettbezügen oder Badetüchern im <font color="#C51F32"><b>s.Oliver</b></font>-Look. Lassen Sie sich alles bequem und kostenlos mit dem Standardversand nach Hause schicken und sparen Sie zusätzlich mit unserem aktuellen <font color="#C51F32"><b>s.Oliver</b></font> Gutschein.

<br><br>

<a href="http://www.coupons4u.de/zum_anbieter.php?mer_id=437" target=_blank>

<img src="http://ad.zanox.com/ppv/?23857823C1183443878"></a>



]]></description>
        </merchant>
        <merchant>
          <id>2</id>
          <name>AllPosters</name>
          <logo>http://www.coupons4u.de/images/mer_logo_437.jpg</logo>
          <description><![CDATA[AllPosters]]></description>
        </merchant>
        <merchant>
          <id>3</id>
          <name>Waschbär</name>
          <logo>http://www.coupons4u.de/images/mer_logo_1069.jpg</logo>
          <description><![CDATA[]]></description>
        </merchant>
        <merchant>
          <id>4</id>
          <name>Air Berlin</name>
          <logo>http://www.coupons4u.de/images/mer_logo_1420.jpg</logo>
          <description><![CDATA[]]></description>
        </merchant>
        <merchant>
          <id>5</id>
          <name>SC24.com</name>
          <logo>http://www.coupons4u.de/images/mer_logo_781.jpg</logo>
          <description><![CDATA[]]></description>
        </merchant>
        <merchant>
          <id>6</id>
          <name>Sneakerspot</name>
          <logo>http://www.coupons4u.de/images/mer_logo_781.jpg</logo>
          <description><![CDATA[]]></description>
        </merchant>
        <merchant>
          <id>7</id>
          <name>OTTO</name>
          <logo>http://www.coupons4u.de/images/mer_logo_386.jpg</logo>
          <description><![CDATA[]]></description>
        </merchant>
        <merchant>
          <id>8</id>
          <name>MEXX</name>
          <logo>http://www.coupons4u.de/images/mer_logo_331.jpg</logo>
          <description><![CDATA[]]></description>
        </merchant>
        <merchant>
          <id>9</id>
          <name>Skill7</name>
          <logo>http://www.coupons4u.de/images/mer_logo_331.jpg</logo>
          <description><![CDATA[]]></description>
        </merchant>
        <merchant>
          <id>10</id>
          <name>Club des Créateurs de Beauté</name>
          <logo>http://www.coupons4u.de/images/mer_logo_93.jpg</logo>
          <description><![CDATA[]]></description>
        </merchant>
      </merchants>
    </response>'
  end
end