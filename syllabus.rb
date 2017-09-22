require 'open-uri'
require 'nokogiri'
require 'mechanize'

$id = 1
$teacher_name = ""

def get_syllabus_url(url)
  charset = 'shift_jis'
  html = open(url) do |f|
    charset = f.charset
    f.read
  end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    doc.css('.resultkougi a').each do |node|
      begin
      get_syllabus("https://syllabus.acc.senshu-u.ac.jp"+node[:href])
      rescue
      puts "特殊文字出現"
      end
    end
end

def get_syllabus(url)
  charset = 'shift_jis'
  html = open(url) do |f|
    charset = f.charset
    f.read
  end

  File.open("syllabus.csv","a") do |csv| 
    doc = Nokogiri::HTML.parse(html, nil, charset)
    if !doc.to_s.match('該当するデータはありません。')
      #puts url
      escapes = ["スペイン語上級演習","数学科教育論","コリア語初級会話","教育実習","コリア語初級基礎","教養テーマゼミナール","コリア語中級会話","コリア語中級総合","ドイツ語上級演習","フランス語中級演習","中国語中級演習","ドイツ語中級演習","フランス語中級総合","コリア語初級構造","総合科目","フランス語初級構造"]
      if escapes.index(doc.css('.section table .syl_data')[0].text) == nil
        kamokumei =  doc.css('.section table .syl_data')[0].text.gsub(/(\r\n|\r|\n)/, "<br />").gsub(",","$").tr('０-９', '0-9')
        puts doc.css('.section table .syl_data')[0].text.gsub(/(\r\n|\r|\n)/, "<br />").gsub(",","$")
        kousimei = doc.css('.section table .syl_data')[1].text.gsub(/(\r\n|\r|\n)/, "<br />").gsub(",","$")
        youbi = doc.css('.section table .syl_data')[2].text.gsub(/(\r\n|\r|\n)/, "<br />")
        zenkouki = doc.css('.section table .syl_data')[3].text.gsub(/(\r\n|\r|\n)/, "<br />").gsub(",","$")
        place  = doc.css('.section table .syl_data')[4].text.gsub(/(\r\n|\r|\n)/, "<br />").gsub(",","$")
        genre = doc.css('.section table .syl_data')[5].text.gsub(/(\r\n|\r|\n)/, "<br />").gsub(",","$")
        gakubu = doc.css('.section table .syl_data')[6].text.gsub(/(\r\n|\r|\n)/, "<br />").gsub(",","$")
        tani = doc.css('.section table .syl_data')[7].text.gsub(/(\r\n|\r|\n)/, "<br />").gsub(",","$")
        body = doc.css('.section table .syl_data')[8].text.gsub(/(\r\n|\r|\n)/, "<br />").gsub(",","$")
        seiseki = doc.css('.section table .syl_data')[9].text.gsub(/(\r\n|\r|\n)/, "<br />").gsub(",","$")
        caution = doc.css('.section table .syl_data')[10].text.gsub(/(\r\n|\r|\n)/, "<br />").gsub(",","$")
        csv.puts("#{$id},#{kamokumei},#{$teacher_name.gsub("　","")},#{youbi},#{zenkouki},#{place},#{genre},#{gakubu},#{tani},#{body},#{seiseki},#{caution}")
        $id = $id + 1
      end
    end    
  end
end

def get_teacher(val)
  agent = Mechanize.new
  agent.user_agent_alias = 'Mac Safari 4'
  agent.get('http://syllabus.acc.senshu-u.ac.jp/syllabus/syllabus/search/Kyoin.do?nendo=2016&setti=1') do |page|
    mypage = page.form_with(:name =>'KyoinBean') do |form|
      form.field_with(:name => 'syozokucode'){|list|
        list.value = val
      }
    end.submit
  end
  page = agent.page
  elements = page.css('a')
  elements.each do |ele|
    if !ele[:href].match('cript') && ele[:href] != 'http://www.senshu-u.ac.jp/'
      $teacher_name =  ele.text
      get_syllabus_url("https://syllabus.acc.senshu-u.ac.jp"+ele[:href])
    end
  end
end
values = ["0110000000","0120000000","0130000000","0140000000","0150000000","0160000000","0165000000","0165000000","0190710000","0190740000"]
values.each do |val|
  get_teacher(val)
end