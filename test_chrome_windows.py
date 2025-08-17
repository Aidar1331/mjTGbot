#!/usr/bin/env python3
"""
Тестовый скрипт для проверки Chrome и ChromeDriver на Windows
"""

import os
import sys
import time
import logging
from pathlib import Path

# Настройка логирования
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def test_chrome_installation():
    """Проверка установки Chrome"""
    chrome_paths = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        r"C:\Users\{}\AppData\Local\Google\Chrome\Application\chrome.exe".format(os.getenv('USERNAME')),
    ]
    
    for path in chrome_paths:
        if os.path.exists(path):
            logger.info(f"✅ Chrome found at: {path}")
            
            # Проверяем версию
            try:
                import subprocess
                result = subprocess.run([path, '--version'], 
                                      capture_output=True, text=True, timeout=10)
                logger.info(f"Chrome version: {result.stdout.strip()}")
                return path
            except Exception as e:
                logger.error(f"Error checking Chrome version: {e}")
        
    logger.error("❌ Chrome not found!")
    return None

def test_chromedriver_installation():
    """Проверка установки ChromeDriver"""
    chromedriver_paths = [
        r"C:\chromedriver\chromedriver.exe",
        r".\chromedriver.exe",
        r"chromedriver.exe"
    ]
    
    for path in chromedriver_paths:
        if os.path.exists(path):
            logger.info(f"✅ ChromeDriver found at: {path}")
            
            # Проверяем версию
            try:
                import subprocess
                result = subprocess.run([path, '--version'], 
                                      capture_output=True, text=True, timeout=10)
                logger.info(f"ChromeDriver version: {result.stdout.strip()}")
                return path
            except Exception as e:
                logger.error(f"Error checking ChromeDriver version: {e}")
    
    logger.warning("⚠️ ChromeDriver not found in standard locations")
    logger.info("Will try to use undetected-chromedriver auto-download")
    return None

def test_selenium_import():
    """Проверка импорта Selenium"""
    try:
        import selenium
        logger.info(f"✅ Selenium imported successfully, version: {selenium.__version__}")
        return True
    except ImportError as e:
        logger.error(f"❌ Failed to import Selenium: {e}")
        return False

def test_undetected_chromedriver():
    """Проверка undetected-chromedriver"""
    try:
        import undetected_chromedriver as uc
        logger.info("✅ undetected-chromedriver imported successfully")
        return True
    except ImportError as e:
        logger.error(f"❌ Failed to import undetected-chromedriver: {e}")
        return False

def test_basic_selenium():
    """Базовый тест Selenium"""
    try:
        logger.info("Testing basic Selenium functionality...")
        
        import undetected_chromedriver as uc
        from selenium.webdriver.common.by import By
        from selenium.webdriver.support.ui import WebDriverWait
        from selenium.webdriver.support import expected_conditions as EC
        
        # Настройка опций
        options = uc.ChromeOptions()
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--disable-gpu")
        options.add_argument("--window-size=1920,1080")
        
        # Найдем Chrome и ChromeDriver
        chrome_path = test_chrome_installation()
        chromedriver_path = test_chromedriver_installation()
        
        driver_kwargs = {"options": options, "version_main": 139}
        
        if chrome_path:
            driver_kwargs["browser_executable_path"] = chrome_path
        if chromedriver_path:
            driver_kwargs["driver_executable_path"] = chromedriver_path
        
        # Создаем драйвер
        logger.info("Creating Chrome driver...")
        driver = uc.Chrome(**driver_kwargs)
        
        try:
            # Тест подключения к Google
            logger.info("Testing navigation to Google...")
            driver.get("https://www.google.com")
            
            # Ждем загрузки
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.NAME, "q"))
            )
            
            logger.info("✅ Successfully navigated to Google!")
            
            # Тест поиска
            search_box = driver.find_element(By.NAME, "q")
            search_box.send_keys("test selenium")
            search_box.submit()
            
            time.sleep(3)
            logger.info("✅ Search functionality works!")
            
        finally:
            driver.quit()
            logger.info("Driver closed successfully")
        
        return True
        
    except Exception as e:
        logger.error(f"❌ Selenium test failed: {e}")
        return False

def test_discord_navigation():
    """Тест навигации к Discord"""
    try:
        logger.info("Testing Discord navigation...")
        
        import undetected_chromedriver as uc
        from selenium.webdriver.common.by import By
        from selenium.webdriver.support.ui import WebDriverWait
        from selenium.webdriver.support import expected_conditions as EC
        
        # Настройка опций
        options = uc.ChromeOptions()
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--disable-gpu")
        options.add_argument("--window-size=1920,1080")
        
        # Найдем пути
        chrome_path = test_chrome_installation()
        chromedriver_path = test_chromedriver_installation()
        
        driver_kwargs = {"options": options, "version_main": 139}
        
        if chrome_path:
            driver_kwargs["browser_executable_path"] = chrome_path
        if chromedriver_path:
            driver_kwargs["driver_executable_path"] = chromedriver_path
        
        # Создаем драйвер
        driver = uc.Chrome(**driver_kwargs)
        
        try:
            # Переходим к Discord
            logger.info("Navigating to Discord login...")
            driver.get("https://discord.com/login")
            
            # Ждем загрузки формы входа
            WebDriverWait(driver, 15).until(
                EC.presence_of_element_located((By.NAME, "email"))
            )
            
            logger.info("✅ Successfully reached Discord login page!")
            
            # Проверяем поля
            email_field = driver.find_element(By.NAME, "email")
            password_field = driver.find_element(By.NAME, "password")
            
            if email_field and password_field:
                logger.info("✅ Login form elements found!")
            
        finally:
            driver.quit()
        
        return True
        
    except Exception as e:
        logger.error(f"❌ Discord navigation test failed: {e}")
        return False

def main():
    """Главная функция тестирования"""
    logger.info("=" * 50)
    logger.info("Windows Chrome/Selenium Test Suite")
    logger.info("=" * 50)
    
    results = {}
    
    # Тест установки Chrome
    results["chrome"] = test_chrome_installation() is not None
    
    # Тест установки ChromeDriver
    results["chromedriver"] = test_chromedriver_installation() is not None
    
    # Тест импорта Selenium
    results["selenium"] = test_selenium_import()
    
    # Тест undetected-chromedriver
    results["undetected"] = test_undetected_chromedriver()
    
    # Базовый тест Selenium
    if results["selenium"] and results["undetected"]:
        results["basic_selenium"] = test_basic_selenium()
        
        if results["basic_selenium"]:
            # Тест Discord навигации
            results["discord"] = test_discord_navigation()
    
    # Результаты
    logger.info("=" * 50)
    logger.info("Test Results:")
    logger.info("=" * 50)
    
    for test_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        logger.info(f"{test_name:20} {status}")
    
    # Общий результат
    all_passed = all(results.values())
    if all_passed:
        logger.info("🎉 All tests passed! System is ready for MJ automation.")
    else:
        logger.error("⚠️  Some tests failed. Please check the issues above.")
        
        # Рекомендации
        if not results.get("chrome"):
            logger.error("Install Google Chrome from https://www.google.com/chrome/")
        if not results.get("chromedriver"):
            logger.error("Download ChromeDriver and place it in C:\\chromedriver\\")
        if not results.get("selenium"):
            logger.error("Install Selenium: pip install selenium")
        if not results.get("undetected"):
            logger.error("Install undetected-chromedriver: pip install undetected-chromedriver")
    
    return 0 if all_passed else 1

if __name__ == "__main__":
    exit(main())