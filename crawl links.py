# Python script to extract mp3 links from artist streams on Kunststaub podcast pages

import requests
from bs4 import BeautifulSoup
import re

# Base URL for crawling
BASE_URL = 'https://www.podcast.de/podcast/3460487/archiv?page={}'

# Function to get the HTML content of a page
def get_page_content(url):
    try:
        print(f"Fetching URL: {url}")
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            print(f"Successfully retrieved URL: {url}")
            return response.text
        else:
            print(f"Failed to retrieve URL: {url} with status code {response.status_code}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Exception occurred while fetching URL: {url} - {e}")
        return None

# Function to extract Kunststaub stream links from the HTML content
def extract_stream_links(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')
    stream_links = []
    # Extract links inside the div with class 'episode-list'
    episode_list_div = soup.find('div', class_='episode-list')
    if episode_list_div:
        for link in episode_list_div.find_all('a', href=True):
            url = link['href']
            if url and re.search(r'/episode/\d+', url):
                if url not in stream_links:
                    stream_links.append(url)
                    print(f"Found stream link: {url}")
    return stream_links

# Crawl through pages and gather Kunststaub stream links
all_stream_links = []
for page in range(1, 16):
    print(f"Crawling page {page}")
    url = BASE_URL.format(page)
    html_content = get_page_content(url)
    if html_content:
        page_stream_links = extract_stream_links(html_content)
        all_stream_links.extend(page_stream_links)
    print(f"Total stream links collected so far: {len(all_stream_links)}")

# Crawl each stream link to extract mp3 links
mp3_links = []
artist_mp3_map = {}
for stream_link in all_stream_links:
    # Ensure the URL is correctly formatted
    if stream_link.startswith('http'):
        full_url = stream_link
    else:
        full_url = f'https://www.podcast.de{stream_link}'
    
    print(f'Starting to crawl stream URL: {full_url}')
    html_content = get_page_content(full_url)
    if html_content:
        soup = BeautifulSoup(html_content, 'html.parser')
        meta_tag = soup.find('meta', attrs={'name': 'twitter:player:stream'})
        if meta_tag and meta_tag.get('content') and meta_tag['content'].endswith('.mp3'):
            mp3_link = meta_tag['content']
            if mp3_link not in mp3_links:  # Avoid duplicates
                mp3_links.append(mp3_link)
                # Extract artist name from the stream link page
                artist_name_tag = soup.find('h1')  # Assuming artist name is in an <h1> tag
                if artist_name_tag:
                    artist_name = artist_name_tag.text.strip()
                    artist_mp3_map[artist_name] = mp3_link
                print(f'Found mp3 link: {mp3_link}')
    else:
        print(f'Failed to retrieve stream URL: {full_url}')

# Print results
print("\nTotal mp3 links found:", len(mp3_links))
print("\nList of mp3 links:")
for link in mp3_links:
    print(link)

# Create a Dart file with artist name and mp3 URL as a map
dart_content = """
// Dart file with artist names and corresponding mp3 links

const Map<String, String> artistMp3Links = {
"""
for artist, mp3_link in artist_mp3_map.items():
    dart_content += f'  "{artist}": "{mp3_link}",\n'
dart_content += "};\n"

# Write to a Dart file
with open('artist_mp3_links.dart', 'w') as dart_file:
    dart_file.write(dart_content)

print("\nDart file 'artist_mp3_links.dart' has been created with artist names and mp3 links.")
