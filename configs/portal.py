#!/usr/bin/env python3
# Portal cautivo mínimo (didáctico): al aceptar, agrega la IP del cliente al set nftables.
import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer

PAGINA = b"<h1>Wi-Fi Invitados UNCuyo</h1><p>Uso academico. <a href=\"/aceptar\">Acepto los terminos</a></p>"

class Portal(BaseHTTPRequestHandler):
    def do_GET(self):
        ip = self.client_address[0]
        if self.path == "/aceptar":
            subprocess.run(["nft", "add", "element", "inet", "tp7", "autorizados", "{ %s }" % ip], check=True)
            cuerpo = b"<h1>Acceso concedido</h1>"
        else:
            cuerpo = PAGINA
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(cuerpo)

HTTPServer(("192.168.30.1", 8080), Portal).serve_forever()
