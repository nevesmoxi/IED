#!/usr/bin/env python3
"""
Gerador de Códigos de Acesso - IED Reader
===========================================

Este script permite ao autor gerar códigos de acesso válidos para dar aos
leitores que compraram o livro fora da Google Play (WhatsApp, transferência
bancária, Multicaixa Express, etc).

Não é necessário nenhum servidor, base de dados ou ligação à Internet: os
códigos são calculados a partir de uma fórmula secreta que só este script e
o próprio aplicativo conhecem. Isto significa que o autor pode gerar quantos
códigos quiser, a qualquer momento, mesmo sem ligação à Internet.

IMPORTANTE:
- Guarde este ficheiro em local seguro (não o publique nem o partilhe).
- A "chave secreta" (SECRET) usada aqui TEM de ser exactamente igual à
  usada em lib/services/access_code_service.dart no aplicativo. Se alguma
  vez precisar de mudar a chave secreta, terá de reemitir todos os códigos
  já dados aos leitores (os antigos deixarão de funcionar).

COMO USAR:

1) Gerar UM código para um comprador específico:
   python3 generate_access_code.py "NOME_OU_TELEFONE_DO_COMPRADOR"

   Exemplo:
   python3 generate_access_code.py "929990606"
   -> IED-929990606-A1B2C3

2) Gerar VÁRIOS códigos sequenciais de uma vez (ex.: para uma pré-venda):
   python3 generate_access_code.py --batch 20
   -> Gera 20 códigos: IED-000001-XXXXXX até IED-000020-XXXXXX

3) Verificar se um código é válido (útil para suporte ao cliente):
   python3 generate_access_code.py --verify "IED-929990606-A1B2C3"

Cada identificador (o texto entre "IED-" e o checksum final) só deve ser
usado UMA VEZ. Sugestão de identificadores: número de telefone do
comprador, número de referência da transferência, ou um número sequencial
(001, 002, 003...) que anote numa folha de registo de vendas.
"""

import hashlib
import hmac
import sys
import re

# Deve ser IDÊNTICO ao valor de `_secret` em
# lib/services/access_code_service.dart
SECRET = "IEDReader-NevesMoxi-2025-AccessCode-Secret"


def normalize(identifier: str) -> str:
    identifier = identifier.strip().upper()
    identifier = re.sub(r"\s+", "", identifier)
    return identifier


def compute_checksum(identifier: str) -> str:
    key = SECRET.encode("utf-8")
    msg = identifier.encode("utf-8")
    digest = hmac.new(key, msg, hashlib.sha256).hexdigest()
    return digest[:6].upper()


def generate_code(identifier: str) -> str:
    identifier = normalize(identifier)
    checksum = compute_checksum(identifier)
    return f"IED-{identifier}-{checksum}"


def verify_code(code: str) -> bool:
    code = normalize(code)
    parts = code.split("-")
    if len(parts) < 3 or parts[0] != "IED":
        return False
    checksum = parts[-1]
    identifier = "-".join(parts[1:-1])
    if not identifier or len(checksum) != 6:
        return False
    return compute_checksum(identifier) == checksum


def main():
    args = sys.argv[1:]

    if not args:
        print(__doc__)
        return

    if args[0] == "--verify" and len(args) == 2:
        code = args[1]
        ok = verify_code(code)
        print(f"Código: {code}")
        print("✅ VÁLIDO" if ok else "❌ INVÁLIDO")
        return

    if args[0] == "--batch" and len(args) == 2:
        try:
            count = int(args[1])
        except ValueError:
            print("Uso: python3 generate_access_code.py --batch <quantidade>")
            return
        print(f"Gerando {count} códigos sequenciais:\n")
        for i in range(1, count + 1):
            identifier = f"{i:06d}"
            code = generate_code(identifier)
            print(code)
        return

    # Modo simples: gerar um único código a partir de um identificador
    identifier = args[0]
    code = generate_code(identifier)
    print(f"Identificador: {normalize(identifier)}")
    print(f"Código de acesso: {code}")
    print("\nEnvie este código ao comprador (WhatsApp, SMS ou email).")


if __name__ == "__main__":
    main()
