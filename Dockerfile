# Use official Python image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Expose port
EXPOSE 5000

# Set environment variable for app environment
ENV APP_ENV=dev

# Run the app
CMD ["python", "app.py"]
