import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
import urllib.request
import uuid
import requests


chrome_options = Options()
chrome_options.add_argument("user-data-dir=selenium")

driver = webdriver.Chrome()
def load():
    global driver

    driver.get("https://discord.gg/")

def prompt(prompt):
    global driver
    ids = []

    elements = driver.find_elements(By.TAG_NAME, 'form')
    for temp in elements:
        for e in temp.find_elements(By.TAG_NAME, 'div'):
            try:
                if e.get_attribute("role") == "textbox":
                    e.click()
                    time.sleep(0.5)
                    e.send_keys(Keys.CONTROL + "a")
                    e.send_keys(Keys.DELETE)

                    e.send_keys("/create")
                    time.sleep(0.5)
                    e.send_keys(" ", prompt, Keys.TAB, "Anime/Manga", Keys.TAB, "Medium (Avg. Wait: 4-8 minutes)", Keys.RETURN)
                    print("send")
            except:
                pass

    time.sleep(4)

    elements = driver.find_elements(By.CLASS_NAME, 'message__80c10')
    for temp in elements:
        try:
            for temp2 in temp.find_elements(By.CLASS_NAME, 'repliedMessage_e2bf4a'):
                for e in temp2.find_elements(By.TAG_NAME, 'span'):
                    if e.text == "michal":
                        print(e.text)

                        temp3 = temp.find_elements(By.CLASS_NAME, 'messageContent__21e69')
                        print(temp3[0].text.split("Prompt ID: ")[1])
                        ids.append(temp3[0].text.split("Prompt ID: ")[1])
        except:
            pass


    return str(max(ids))

def toggle():
    elements = driver.find_elements(By.CLASS_NAME, 'iconWrapper_af9215')
    for e in elements:
        if e.get_attribute("aria-label") == "Inbox":
            e.click()
            print("toggled")
def get_src(promptId):
    src = None

    while src == None:
        print("tried")
        elements = driver.find_elements(By.CLASS_NAME, 'container__56e52')
        for temp in elements:
            for temp2 in temp.find_elements(By.CLASS_NAME, 'messageContent__21e69'):
                if promptId in temp2.text:
                    for e in temp.find_elements(By.TAG_NAME, 'video'):
                        data = requests.get(e.get_attribute('poster')).content
                        img = "./static/" + str(uuid.uuid4()) + ".jpg"
                        f = open(img, 'wb')

                        f.write(data)
                        f.close()

                        print(e.get_attribute('src'))
                        data = requests.get(e.get_attribute('src')).content
                        vid = "./static/" + str(uuid.uuid4()) + ".mp4"
                        f = open(vid, 'wb')

                        f.write(data)
                        f.close()


                        src = {"img":img.replace("./","/"), "vid":vid.replace("./","/")}
                        print(src)

        time.sleep(15)


    return src

def scrollDown():
    try:
        elements = driver.find_elements(By.CLASS_NAME, 'scroller__1f96e')
        print(elements)
        elements[0].click()
        elements[0].send_keys(Keys.END)
    except:
        pass


