
from lxml import etree  # xml 파일을 열 때 사용하는 코드
import xml.etree.ElementTree as ElementTree  # xml파일을 여는 코드
import pandas as pd

from urllib.request import urlopen

import json
import xmltodict
from xml.sax import handler, parseString

from collections import defaultdict

data = []

for i in range(1, 513):  # 513

    # api주소 열기 (url + 인증키 + 해당페이지+한 화면에 출력되는 데이터 개수)
    # serviceKey= 다음에 인증키 입력
    request = urllib.request.Request(
        'http://apis.data.go.kr/1471057/MdcinPrductPrmisnInfoService/getMdcinPrductItem?serviceKey=input: service key&pageNo=' + str(
            i) + '&numOfRows=100')

    request.get_method = lambda: 'GET'
    response_body = urlopen(request).read()

    # 추출된 xml형식의 text를 xml객체로 파싱
    tree = etree.fromstring(response_body)

    jsonString = json.dumps(xmltodict.parse(response_body))

    rDD = json.loads(jsonString)

    w_data = rDD["response"]["body"]["items"]["item"]

    for name_data in w_data:

        group_data = dict()
        dosage = dict()

        try:
            group_data["item_code"] = name_data["ITEM_SEQ"]
            group_data["item_name"] = name_data["ITEM_NAME"]
            group_data["storage_method"] = name_data["STORAGE_METHOD"]
            group_data["validterm"] = name_data["VALID_TERM"]
            group_data["cancel_name"] = name_data["CANCEL_NAME"]
            group_data["EE_DOC_DATA"] = name_data["EE_DOC_DATA"]["DOC"]["SECTION"]["ARTICLE"]
            group_data["UD_DOC_DATA"] = name_data["UD_DOC_DATA"]["DOC"]["SECTION"]["ARTICLE"]

        except TypeError:
            try:
                for i in range(len(name_data["EE_DOC_DATA"]["DOC"]["SECTION"])):
                    group_data["EE_DOC_DATA"] = name_data["EE_DOC_DATA"]["DOC"]["SECTION"][i]['ARTICLE']
                for i in range(len(name_data["UD_DOC_DATA"]["DOC"]["SECTION"])):
                    group_data["UD_DOC_DATA"] = name_data["UD_DOC_DATA"]["DOC"]["SECTION"][i]['ARTICLE']
            except:
                pass

        data.append(group_data)

total_dosage = []
for x in range(len(data)):

    dosage = []

    try:
        if type(data[x]['UD_DOC_DATA'])==list:
            for i in range(len(data[x]['UD_DOC_DATA'])):
                dosage.append(data[x]['UD_DOC_DATA'][i]['@title'])
                try:
                    if type(data[x]['UD_DOC_DATA'][i]['PARAGRAPH'])==list:
                        for y in data[x]['UD_DOC_DATA'][i]['PARAGRAPH']:
                            value_ = list(y.values())
                            del value_[0:3]
                            dosage.append(''.join(value_))
                    else:
                        dosage.append(data[x]['UD_DOC_DATA'][i]['PARAGRAPH']['#text'])

                except KeyError:
                    if type(data[x]['UD_DOC_DATA'][i])==list:
                        for y in data[x]['UD_DOC_DATA'][i]['PARAGRAPH']:
                            value_ = list(y.values())
                            del value_[0:3]
                            dosage.append(''.join(value_))

        else:
            dosage.append(data[x]['UD_DOC_DATA']['@title'])

            try:
                if type(data[x]['UD_DOC_DATA']['PARAGRAPH'])==list:
                    for y in data[x]['UD_DOC_DATA']['PARAGRAPH']:
                        value_ = list(y.values())
                        del value_[0:3]
                        dosage.append(''.join(value_))

                elif type(data[x]['UD_DOC_DATA']['PARAGRAPH'])==dict:
                    dosage.append(data[x]['UD_DOC_DATA']['PARAGRAPH']['#text'])
            except KeyError:
              pass
    except KeyError:
        pass

    total_dosage.append(dosage)

# 이중리스트 일차로 변환
for a in range(len(total_dosage)):
    total_dosage[a] = [v for v in total_dosage[a] if v]

total_effect = []
for x in range(len(data)):

    dosage = []
    try:
        if type(data[x]['EE_DOC_DATA']) == list:
            for i in range(len(data[x]['EE_DOC_DATA'])):
                dosage.append(data[x]['EE_DOC_DATA'][i]['@title'])
                try:
                    if type(data[x]['EE_DOC_DATA'][i]['PARAGRAPH']) == list:
                        for y in data[x]['EE_DOC_DATA'][i]['PARAGRAPH']:
                            value_ = list(y.values())
                            del value_[0:3]
                            dosage.append(''.join(value_))

                    elif type(data[x]['EE_DOC_DATA'][i]['PARAGRAPH']) == dict:
                        dosage.append(data[x]['EE_DOC_DATA'][i]['PARAGRAPH']['#text'])

                except KeyError:
                    pass

        else:
            dosage.append(data[x]['EE_DOC_DATA']['@title'])

            try:
                if type(data[x]['EE_DOC_DATA']['PARAGRAPH']) == list:
                    for y in data[x]['EE_DOC_DATA']['PARAGRAPH']:
                        value_ = list(y.values())
                        del value_[0:3]
                        dosage.append(''.join(value_))

                elif type(data[x]['EE_DOC_DATA']['PARAGRAPH']) == dict:
                    dosage.append(data[x]['EE_DOC_DATA']['PARAGRAPH']['#text'])

            except KeyError:
                pass

    except KeyError:
        pass

    total_effect.append(dosage)

for a in range(len(total_effect)):
    total_effect[a] = [v for v in total_effect[a] if v]

data_total = pd.DataFrame(data,columns=['item_code','item_name', 'storage_method', 'validterm','cancel_name'])
data_plus = pd.DataFrame(data={'ee_doc':total_effect,'ud_doc':total_dosage},columns=['ee_doc','ud_doc'])

data_plus['ee_doc'] = data_plus['ee_doc'].replace('\n','',regex=True)
data_plus['ud_doc'] = data_plus['ud_doc'].replace('\n','',regex=True)

data2 = pd.concat([data_total,data_plus],axis=1)

data2['ee_doc']  = data2['ee_doc'].apply(lambda x:'\n'.join(x))
data2['ud_doc']  = data2['ud_doc'].apply(lambda x:'\n'.join(x))

data2['ee_doc'] = data2['ee_doc'].replace(['&#8226','</span>','<span style="font-family:바탕; letter-spacing:0pt; mso-fareast-font-family:바탕; mso-font-width:100%; mso-text-raise:0pt">','\n&lt','&gt','<sub>','<p>','</p>','<td>','</td>','</sub>','</sup>','<sup>',';','&#8226','&#x301c','\xad','&nbsp','&#x2022;','&lt;표2&gt;','<tbody>','</tbody>','<tr>','</tr>',' \n <tr> \n  <td> <p class="indent3">체중(Kg)</p> </td> \n  <td> <p class="indent3">중증감염 시 상용량</p> <p class="indent3">(1mg/Kg씩 8시간마다)</p> </td> \n  <td> <p class="indent3">생명위급시 용량</p> <p class="indent3">(1.7mg/Kg씩 8시간마다)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">40</p> </td> \n  <td> <p class="indent3">1.0mL(40mg)</p> </td> \n  <td> <p class="indent3">1.6mL(66mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">45</p> </td> \n  <td> <p class="indent3">1.1mL(45mg)</p> </td> \n  <td> <p class="indent3">1.9mL(75mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">50</p> </td> \n  <td> <p class="indent3">1.25mL(50mg)</p> </td> \n  <td> <p class="indent3">2.1mL(83mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">55</p> </td> \n  <td> <p class="indent3">1.4mL(55mg)</p> </td> \n  <td> <p class="indent3">2.25mL(91mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">60</p> </td> \n  <td> <p class="indent3">1.5mL(60mg)</p> </td> \n  <td> <p class="indent3">2.5mL(100mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">65</p> </td> \n  <td> <p class="indent3">1.6mL(65mg)</p> </td> \n  <td> <p class="indent3">2.7mL(108mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">70</p> </td> \n  <td> <p class="indent3">1.75mL(70mg)</p> </td> \n  <td> <p class="indent3">2.9mL(116mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">75</p> </td> \n  <td> <p class="indent3">1.9mL(75mg)</p> </td> \n  <td> <p class="indent3">3.1mL(125mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">80</p> </td> \n  <td> <p class="indent3">2.0mL(80mg)</p> </td> \n  <td> <p class="indent3">3.3mL(133mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">85</p> </td> \n  <td> <p class="indent3">2.1mL(85mg)</p> </td> \n  <td> <p class="indent3">3.5mL(141mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">90</p> </td> \n  <td> <p class="indent3">2.25mL(90mg)</p> </td> \n  <td> <p class="indent3">3.75mL(150mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">95</p> </td> \n  <td> <p class="indent3">2.4mL(95mg)</p> </td> \n  <td> <p class="indent3">4.0mL(158mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">100</p> </td> \n  <td> <p class="indent3">2.5mL(100mg)</p> </td> \n  <td> <p class="indent3">4.2mL(166mg)</p> </td> \n </tr> \n</tbody>','<tbody> \n <tr> \n  <td> <p class="indent3">혈청 크레아티닌 (mg %)</p> </td> \n  <td> <p class="indent3">크레아티닌청소율의 개략치</p> <p class="indent3">(mL/min/1.73㎡)</p> </td> \n  <td> <p class="indent3">정상신장기능환자의</p> <p class="indent3">용량에 대한 백분율</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">≤ 1.0</p> </td> \n  <td> <p class="indent3">&gt; 100</p> </td> \n  <td> <p class="indent3">100</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">1.1 - 1.3</p> </td> \n  <td> <p class="indent3">70 - 100</p> </td> \n  <td> <p class="indent3">80</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">1.4 - 1.6</p> </td> \n  <td> <p class="indent3">55 - 70</p> </td> \n  <td> <p class="indent3">65</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">1.7 - 1.9</p> </td> \n  <td> <p class="indent3">45 - 55</p> </td> \n  <td> <p class="indent3">55</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">2.0 - 2.2</p> </td> \n  <td> <p class="indent3">40 - 45</p> </td> \n  <td> <p class="indent3">50</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">2.3 - 2.5</p> </td> \n  <td> <p class="indent3">35 - 40</p> </td> \n  <td> <p class="indent3">40</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">2.6 - 3.0</p> </td> \n  <td> <p class="indent3">30 - 35</p> </td> \n  <td> <p class="indent3">35</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">3.1 - 3.5</p> </td> \n  <td> <p class="indent3">25 - 30</p> </td> \n  <td> <p class="indent3">30</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">3.6 - 4.0</p> </td> \n  <td> <p class="indent3">20 - 25</p> </td> \n  <td> <p class="indent3">25</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">4.1 - 5.1</p> </td> \n  <td> <p class="indent3">15 - 20</p> </td> \n  <td> <p class="indent3">20</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">5.2 - 6.6</p> </td> \n  <td> <p class="indent3">10 - 15</p> </td> \n  <td> <p class="indent3">15</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">6.7 - 8.0</p> </td> \n  <td> <p class="indent3">&lt; 10</p> </td> \n  <td> <p class="indent3">10</p> </td> \n </tr> \n</tbody>','<tbody> \n <tr> \n  <td> <p>연령</p> </td> \n  <td> <p>몸무게(kg)</p> </td> \n  <td> <p>아세트아미노펜으로서 용량</p> </td> \n  <td> <p>1회용량</p> </td> \n </tr> \n <tr> \n  <td> <p>만 12세</p> </td> \n  <td> <p>43kg 이상</p> </td> \n  <td> <p>640mg</p> </td> \n  <td> <p>20ml</p> </td> \n </tr> \n <tr> \n  <td> <p>만 11세</p> </td> \n  <td> <p>38.0~42.9kg</p> </td> \n  <td> <p>480mg</p> </td> \n  <td> <p>15ml</p> </td> \n </tr> \n <tr> \n  <td> <p>만 9-10세</p> </td> \n  <td> <p>30.0~37.9kg</p> </td> \n  <td> <p>400mg</p> </td> \n  <td> <p>12.5ml</p> </td> \n </tr> \n <tr> \n  <td> <p>만 6-8세</p> </td> \n  <td> <p>21.0~29.9kg</p> </td> \n  <td> <p>320mg</p> </td> \n  <td> <p>10ml</p> </td> \n </tr> \n <tr> \n  <td> <p>만 4-5세</p> </td> \n  <td> <p>16.0~20.9kg</p> </td> \n  <td> <p>240mg</p> </td> \n  <td> <p>7.5ml</p> </td> \n </tr> \n <tr> \n  <td> <p>만 2-3세</p> </td> \n  <td> <p>12.0~15.9kg</p> </td> \n  <td> <p>160mg</p> </td> \n  <td> <p>5ml</p> </td> \n </tr> \n <tr> \n  <td> <p>12-23개월</p> </td> \n  <td> <p>10.0~11.9kg</p> </td> \n  <td> <p>120mg</p> </td> \n  <td> <p>3.5ml</p> </td> \n </tr> \n <tr> \n  <td> <p>4-11개월</p> </td> \n  <td> <p>7.0~ 9.9kg</p> </td> \n  <td> <p>80mg</p> </td> \n  <td> <p>2.5ml</p> </td> \n </tr> \n</tbody>','<tbody> \n <tr> \n  <td rowspan="2" valign="top"> <p>CLcr(ml/min) =</p> </td> \n  <td valign="top"> <p>[140-연령(세)] X 체중(kg)</p> </td> \n  <td rowspan="2" valign="top"> <p>(여성인 경우X0.85)</p> </td> \n </tr> \n <tr> \n  <td valign="top"> <p>72 X 혈청 크레아티닌(mg/dl)</p> </td> \n </tr> \n</tbody>','<tbody> \n <tr> \n  <td valign="top"> <p>분류</p> </td> \n  <td valign="top"> <p>크레아티닌 청소율</p> <p>(ml/min)</p> </td> \n  <td valign="top"> <p>용법 용량</p> </td> \n </tr> \n <tr> \n  <td valign="top"> <p>정상</p> </td> \n  <td valign="top"> <p>≥ 80</p> </td> \n  <td valign="top"> <p>1일 용량과 동일, 2~4회 분할 투여</p> </td> \n </tr> \n <tr> \n  <td valign="top"> <p>경증</p> </td> \n  <td valign="top"> <p>50-79</p> </td> \n  <td valign="top"> <p>1일 용량의 2/3, 2~3회 분할 투여</p> </td> \n </tr> \n <tr> \n  <td valign="top"> <p>중등도</p> </td> \n  <td valign="top"> <p>30-49</p> </td> \n  <td valign="top"> <p>1일 용량의 1/3, 2회 분할 투여</p> </td> \n </tr> \n <tr> \n  <td valign="top"> <p>중증</p> </td> \n  <td valign="top"> <p>&lt; 30</p> </td> \n  <td valign="top"> <p>1일 용량의 1/6, 1회 투여</p> </td> \n </tr> \n <tr> \n  <td valign="top"> </td> \n  <td valign="top"> <p>&lt; 20</p> </td> \n  <td valign="top"> <p>투여 금기</p> </td> \n </tr> \n</tbody>'], '', regex=True)
data2['ud_doc'] = data2['ud_doc'].replace(['&#8226','</span>','<span style="font-family:바탕; letter-spacing:0pt; mso-fareast-font-family:바탕; mso-font-width:100%; mso-text-raise:0pt">','\n&lt','&gt','<sub>','<p>','</p>','<td>','</td>','</sub>','</sup>','<sup>',';','&#8226','&#x301c','\xad','&nbsp','&#x2022;','&lt;표2&gt;','<tbody>','</tbody>','<tr>','</tr>',' \n <tr> \n  <td> <p class="indent3">체중(Kg)</p> </td> \n  <td> <p class="indent3">중증감염 시 상용량</p> <p class="indent3">(1mg/Kg씩 8시간마다)</p> </td> \n  <td> <p class="indent3">생명위급시 용량</p> <p class="indent3">(1.7mg/Kg씩 8시간마다)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">40</p> </td> \n  <td> <p class="indent3">1.0mL(40mg)</p> </td> \n  <td> <p class="indent3">1.6mL(66mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">45</p> </td> \n  <td> <p class="indent3">1.1mL(45mg)</p> </td> \n  <td> <p class="indent3">1.9mL(75mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">50</p> </td> \n  <td> <p class="indent3">1.25mL(50mg)</p> </td> \n  <td> <p class="indent3">2.1mL(83mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">55</p> </td> \n  <td> <p class="indent3">1.4mL(55mg)</p> </td> \n  <td> <p class="indent3">2.25mL(91mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">60</p> </td> \n  <td> <p class="indent3">1.5mL(60mg)</p> </td> \n  <td> <p class="indent3">2.5mL(100mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">65</p> </td> \n  <td> <p class="indent3">1.6mL(65mg)</p> </td> \n  <td> <p class="indent3">2.7mL(108mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">70</p> </td> \n  <td> <p class="indent3">1.75mL(70mg)</p> </td> \n  <td> <p class="indent3">2.9mL(116mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">75</p> </td> \n  <td> <p class="indent3">1.9mL(75mg)</p> </td> \n  <td> <p class="indent3">3.1mL(125mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">80</p> </td> \n  <td> <p class="indent3">2.0mL(80mg)</p> </td> \n  <td> <p class="indent3">3.3mL(133mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">85</p> </td> \n  <td> <p class="indent3">2.1mL(85mg)</p> </td> \n  <td> <p class="indent3">3.5mL(141mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">90</p> </td> \n  <td> <p class="indent3">2.25mL(90mg)</p> </td> \n  <td> <p class="indent3">3.75mL(150mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">95</p> </td> \n  <td> <p class="indent3">2.4mL(95mg)</p> </td> \n  <td> <p class="indent3">4.0mL(158mg)</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">100</p> </td> \n  <td> <p class="indent3">2.5mL(100mg)</p> </td> \n  <td> <p class="indent3">4.2mL(166mg)</p> </td> \n </tr> \n</tbody>','<tbody> \n <tr> \n  <td> <p class="indent3">혈청 크레아티닌 (mg %)</p> </td> \n  <td> <p class="indent3">크레아티닌청소율의 개략치</p> <p class="indent3">(mL/min/1.73㎡)</p> </td> \n  <td> <p class="indent3">정상신장기능환자의</p> <p class="indent3">용량에 대한 백분율</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">≤ 1.0</p> </td> \n  <td> <p class="indent3">&gt; 100</p> </td> \n  <td> <p class="indent3">100</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">1.1 - 1.3</p> </td> \n  <td> <p class="indent3">70 - 100</p> </td> \n  <td> <p class="indent3">80</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">1.4 - 1.6</p> </td> \n  <td> <p class="indent3">55 - 70</p> </td> \n  <td> <p class="indent3">65</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">1.7 - 1.9</p> </td> \n  <td> <p class="indent3">45 - 55</p> </td> \n  <td> <p class="indent3">55</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">2.0 - 2.2</p> </td> \n  <td> <p class="indent3">40 - 45</p> </td> \n  <td> <p class="indent3">50</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">2.3 - 2.5</p> </td> \n  <td> <p class="indent3">35 - 40</p> </td> \n  <td> <p class="indent3">40</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">2.6 - 3.0</p> </td> \n  <td> <p class="indent3">30 - 35</p> </td> \n  <td> <p class="indent3">35</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">3.1 - 3.5</p> </td> \n  <td> <p class="indent3">25 - 30</p> </td> \n  <td> <p class="indent3">30</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">3.6 - 4.0</p> </td> \n  <td> <p class="indent3">20 - 25</p> </td> \n  <td> <p class="indent3">25</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">4.1 - 5.1</p> </td> \n  <td> <p class="indent3">15 - 20</p> </td> \n  <td> <p class="indent3">20</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">5.2 - 6.6</p> </td> \n  <td> <p class="indent3">10 - 15</p> </td> \n  <td> <p class="indent3">15</p> </td> \n </tr> \n <tr> \n  <td> <p class="indent3">6.7 - 8.0</p> </td> \n  <td> <p class="indent3">&lt; 10</p> </td> \n  <td> <p class="indent3">10</p> </td> \n </tr> \n</tbody>','<tbody> \n <tr> \n  <td> <p>연령</p> </td> \n  <td> <p>몸무게(kg)</p> </td> \n  <td> <p>아세트아미노펜으로서 용량</p> </td> \n  <td> <p>1회용량</p> </td> \n </tr> \n <tr> \n  <td> <p>만 12세</p> </td> \n  <td> <p>43kg 이상</p> </td> \n  <td> <p>640mg</p> </td> \n  <td> <p>20ml</p> </td> \n </tr> \n <tr> \n  <td> <p>만 11세</p> </td> \n  <td> <p>38.0~42.9kg</p> </td> \n  <td> <p>480mg</p> </td> \n  <td> <p>15ml</p> </td> \n </tr> \n <tr> \n  <td> <p>만 9-10세</p> </td> \n  <td> <p>30.0~37.9kg</p> </td> \n  <td> <p>400mg</p> </td> \n  <td> <p>12.5ml</p> </td> \n </tr> \n <tr> \n  <td> <p>만 6-8세</p> </td> \n  <td> <p>21.0~29.9kg</p> </td> \n  <td> <p>320mg</p> </td> \n  <td> <p>10ml</p> </td> \n </tr> \n <tr> \n  <td> <p>만 4-5세</p> </td> \n  <td> <p>16.0~20.9kg</p> </td> \n  <td> <p>240mg</p> </td> \n  <td> <p>7.5ml</p> </td> \n </tr> \n <tr> \n  <td> <p>만 2-3세</p> </td> \n  <td> <p>12.0~15.9kg</p> </td> \n  <td> <p>160mg</p> </td> \n  <td> <p>5ml</p> </td> \n </tr> \n <tr> \n  <td> <p>12-23개월</p> </td> \n  <td> <p>10.0~11.9kg</p> </td> \n  <td> <p>120mg</p> </td> \n  <td> <p>3.5ml</p> </td> \n </tr> \n <tr> \n  <td> <p>4-11개월</p> </td> \n  <td> <p>7.0~ 9.9kg</p> </td> \n  <td> <p>80mg</p> </td> \n  <td> <p>2.5ml</p> </td> \n </tr> \n</tbody>','<tbody> \n <tr> \n  <td rowspan="2" valign="top"> <p>CLcr(ml/min) =</p> </td> \n  <td valign="top"> <p>[140-연령(세)] X 체중(kg)</p> </td> \n  <td rowspan="2" valign="top"> <p>(여성인 경우X0.85)</p> </td> \n </tr> \n <tr> \n  <td valign="top"> <p>72 X 혈청 크레아티닌(mg/dl)</p> </td> \n </tr> \n</tbody>','<tbody> \n <tr> \n  <td valign="top"> <p>분류</p> </td> \n  <td valign="top"> <p>크레아티닌 청소율</p> <p>(ml/min)</p> </td> \n  <td valign="top"> <p>용법 용량</p> </td> \n </tr> \n <tr> \n  <td valign="top"> <p>정상</p> </td> \n  <td valign="top"> <p>≥ 80</p> </td> \n  <td valign="top"> <p>1일 용량과 동일, 2~4회 분할 투여</p> </td> \n </tr> \n <tr> \n  <td valign="top"> <p>경증</p> </td> \n  <td valign="top"> <p>50-79</p> </td> \n  <td valign="top"> <p>1일 용량의 2/3, 2~3회 분할 투여</p> </td> \n </tr> \n <tr> \n  <td valign="top"> <p>중등도</p> </td> \n  <td valign="top"> <p>30-49</p> </td> \n  <td valign="top"> <p>1일 용량의 1/3, 2회 분할 투여</p> </td> \n </tr> \n <tr> \n  <td valign="top"> <p>중증</p> </td> \n  <td valign="top"> <p>&lt; 30</p> </td> \n  <td valign="top"> <p>1일 용량의 1/6, 1회 투여</p> </td> \n </tr> \n <tr> \n  <td valign="top"> </td> \n  <td valign="top"> <p>&lt; 20</p> </td> \n  <td valign="top"> <p>투여 금기</p> </td> \n </tr> \n</tbody>'], '', regex=True)

data2.shape

