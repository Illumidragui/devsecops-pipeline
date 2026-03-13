#!/bin/bash
set -e

echo "🔧 Creando entorno virtual..."
python -m venv venv

echo "⚡ Activando venv..."
source venv/bin/activate

echo "📦 Instalando dependencias..."
pip install --upgrade pip
pip install -r requirements.txt

echo "✅ Setup completo. Para activar el entorno:"
echo "   source venv/bin/activate"