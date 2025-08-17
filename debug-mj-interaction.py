#!/usr/bin/env python3
"""
Отладочный скрипт для диагностики проблем mj-interaction агента
"""
import subprocess
import json
import sys

def run_command(cmd):
    """Выполнить команду и вернуть результат"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30)
        return result.stdout, result.stderr, result.returncode
    except Exception as e:
        return "", str(e), 1

def main():
    print("🔍 Диагностика mj-interaction агента")
    print("=" * 50)
    
    # 1. Проверка статуса контейнера
    print("\n1. Статус контейнера:")
    stdout, stderr, code = run_command("docker compose ps mj-interaction")
    print(stdout)
    if stderr:
        print("STDERR:", stderr)
    
    # 2. Логи контейнера
    print("\n2. Последние логи:")
    stdout, stderr, code = run_command("docker compose logs --tail=50 mj-interaction")
    print(stdout)
    if stderr:
        print("STDERR:", stderr)
    
    # 3. Проверка переменных окружения
    print("\n3. Переменные окружения:")
    stdout, stderr, code = run_command("docker compose exec -T mj-interaction-agent printenv | grep -E '(DISCORD|PROXY|CHROME|DISPLAY)'")
    print(stdout)
    
    # 4. Проверка Chrome
    print("\n4. Проверка Chrome в контейнере:")
    stdout, stderr, code = run_command("docker compose exec -T mj-interaction-agent google-chrome --version")
    print("Chrome version:", stdout)
    if stderr:
        print("Chrome error:", stderr)
    
    # 5. Проверка Python модулей
    print("\n5. Python модули:")
    stdout, stderr, code = run_command("docker compose exec -T mj-interaction-agent python -c 'import undetected_chromedriver as uc; print(\"UC version:\", uc.__version__)'")
    print(stdout)
    if stderr:
        print("UC error:", stderr)
    
    # 6. Попытка запуска теста Chrome
    print("\n6. Тест Chrome в headless режиме:")
    test_script = '''
import undetected_chromedriver as uc
import sys
try:
    options = uc.ChromeOptions()
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")  
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    driver = uc.Chrome(options=options, version_main=None)
    driver.get("https://www.google.com")
    print("Chrome test: SUCCESS")
    driver.quit()
except Exception as e:
    print(f"Chrome test: FAILED - {e}")
    sys.exit(1)
'''
    
    stdout, stderr, code = run_command(f"docker compose exec -T mj-interaction-agent python -c '{test_script}'")
    print(stdout)
    if stderr:
        print("Test error:", stderr)
    
    print("\n" + "=" * 50)
    print("Диагностика завершена. Проверьте результаты выше.")

if __name__ == "__main__":
    main()