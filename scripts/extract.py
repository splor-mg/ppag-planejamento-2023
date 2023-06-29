from frictionless import Package
import requests
from bs4 import BeautifulSoup
import logging
import shutil
from datetime import datetime
import re
import pytz

logger = logging.getLogger(__name__)

def extract_resource(resource_name: str, descriptor: str = 'datapackage.yaml'):
    package = Package(descriptor)
    resource = package.get_resource(resource_name)

    # 22:04:01 - Geração de Arquivos Texto, aguarde esse processamento pode ser um pouco demorado!
    # ATENÇÃO: Ao abrir o arquivo no Excel use o caracter | como separador de campos
    # 22:05:14 - Arquivo : programas_planejamento.txt gerado com sucesso!!!
    # Tempo de Processamento 00:01:13
    logger.info(f"Geração de arquivo texto para {resource_name}. Aguarde esse processamento pode ser um pouco demorado!")
    res = requests.get(resource.custom['api_url']) # Resource is stripping url property
    res.raise_for_status()
    if 'gerado com sucesso!' not in res.text:
        logger.error('Erro na geração do arquivo texto')
        raise Exception
    
    soup = BeautifulSoup(res.text, 'html.parser')
    
    for p in soup.find_all('p'):
        if 'gerado com sucesso!' in p.get_text():
            logger.info(p.get_text().strip())
            today = datetime.now(pytz.timezone('America/Sao_Paulo'))
            time_pattern = re.compile(r'\b(\d{2}:\d{2}:\d{2})\b')
            time_match = time_pattern.search(p.get_text().strip())

            if time_match is not None:
                time_str = time_match.group(1)
                parsed_time = datetime.strptime(time_str, "%H:%M:%S")
                parsed_datetime = datetime(today.year, today.month, today.day,
                                    parsed_time.hour, parsed_time.minute, parsed_time.second, tzinfo=pytz.timezone('America/Sao_Paulo'))

                logger.info(parsed_datetime)
            else:
                logger.warning('Horário de finalização do processamento não encontrado')

    for p in soup.find_all('p'):
        if 'Tempo de Processamento' in p.get_text():
            logger.info(p.get_text().strip())

    res = requests.get(resource.custom['download_url'], stream=True)
    res.raise_for_status()
    res.raw.decode_content = True
    
    with open(resource.path, 'wb') as file:
        shutil.copyfileobj(res.raw, file)
