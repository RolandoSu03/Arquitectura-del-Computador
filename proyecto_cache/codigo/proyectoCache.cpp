#include <iostream>
#include <vector>
#include <random>
#include <algorithm>
#include <chrono>
#include <map>
#include <iomanip>  
#include <numeric> 

using namespace std;

class CacheAnalyzer {
private:
    long long memory_access_count;
    long long cache_misses;
    int cache_line_size;
    int cache_size;
    map<size_t, bool> cache_lines;
    
public:
    CacheAnalyzer(int line_size = 64, int size = 8192){
        this->cache_line_size = line_size; 
        this->cache_size = size;
        resetCounters();
    }
    
    void resetCounters() {
        memory_access_count = 0;
        cache_misses = 0;
        cache_lines.clear();    // Limpia el mapa o diccionario de cache
    }
    
    // Simular acceso a memoria mejorado
    void memoryAccess(const void* address) {
        memory_access_count++;
        
        // Calcular dirección de línea de caché
        size_t line_address = (reinterpret_cast<size_t>(address) / cache_line_size) * cache_line_size;
        
        // Verificar si es un fallo de caché
        if (!cache_lines[line_address]) {
            cache_misses++;
            cache_lines[line_address] = true;
            
            // Simular política de reemplazo LRU simple
            if (cache_lines.size() > static_cast<size_t>(cache_size / cache_line_size)) {
                cache_lines.erase(cache_lines.begin());
            }
        }
    }
    
    long long getMemoryAccessCount() const { return memory_access_count; }
    long long getCacheMisses() const { return cache_misses; }
    double getCacheHitRate() const {
        if (memory_access_count == 0) {
            return 0.0;
        } else {
            return 1.0 - static_cast<double>(cache_misses) / memory_access_count;
        }
    }
    int getCacheLineSize() const { return cache_line_size; }
    int getCacheSize() const { return cache_size; }
};

template<typename Element>
void insertionSort(vector<Element>& arr, int left, int right, CacheAnalyzer& analyzer) {
    for (int i = left + 1; i <= right; ++i) {
        Element key = arr[i];
        analyzer.memoryAccess(&arr[i]);
        int j = i - 1;
        while (j >= left && arr[j] > key) {
            arr[j + 1] = arr[j];
            analyzer.memoryAccess(&arr[j]);
            --j;
        }
        arr[j + 1] = key;
        analyzer.memoryAccess(&arr[j + 1]);
    }
}

// QuickSort optimizado con blocking y con análisis de caché
template<typename Element>
void blockingQuickSort(vector<Element>& arr, int left, int right, CacheAnalyzer& analyzer) {
    if (left >= right) return;

    // Toma la mitad de la capacidad de cache
    int cacheCapacity = (analyzer.getCacheSize() / analyzer.getCacheLineSize()) / 8;

    // Toma 32 u otro numero fijo como umbral
    //int cacheCapacity = 32;

    if (right - left < cacheCapacity) { // Umbral para usar Insertion Sort
        insertionSort(arr, left, right, analyzer);
        return;
    }
    
    // Elegir pivote en el medio
    int pivot_idx = left + (right - left) / 2;
    Element pivot = arr[pivot_idx];
    analyzer.memoryAccess(&arr[pivot_idx]);
    
    int i = left, j = right;
    while (i <= j) {
        // Mover i hacia la derecha
        while (arr[i] < pivot) {
            analyzer.memoryAccess(&arr[i]);
            i++;
        }
        // Mover j hacia la izquierda
        while (arr[j] > pivot) {
            analyzer.memoryAccess(&arr[j]);
            j--;
        }
        
        // Intercambiar si es necesario
        if (i <= j) {
            analyzer.memoryAccess(&arr[i]);
            analyzer.memoryAccess(&arr[j]);
            swap(arr[i], arr[j]);
            i++;
            j--;
        }
    }
    
    // Llamadas recursivas
    if (left < j) blockingQuickSort(arr, left, j, analyzer);
    if (i < right) blockingQuickSort(arr, i, right, analyzer);
}

// QuickSort optimizado con análisis de caché
template<typename Element>
void normalQuickSort(vector<Element>& arr, int left, int right, CacheAnalyzer& analyzer) {
    if (left >= right) return;
    
    // Elegir pivote en el medio
    int pivot_idx = left + (right - left) / 2;
    Element pivot = arr[pivot_idx];
    analyzer.memoryAccess(&arr[pivot_idx]);
    
    int i = left, j = right;
    while (i <= j) {
        // Mover i hacia la derecha
        while (arr[i] < pivot) {
            analyzer.memoryAccess(&arr[i]);
            i++;
        }
        // Mover j hacia la izquierda
        while (arr[j] > pivot) {
            analyzer.memoryAccess(&arr[j]);
            j--;
        }
        
        // Intercambiar si es necesario
        if (i <= j) {
            analyzer.memoryAccess(&arr[i]);
            analyzer.memoryAccess(&arr[j]);
            swap(arr[i], arr[j]);
            i++;
            j--;
        }
    }
    
    // Llamadas recursivas
    if (left < j) normalQuickSort(arr, left, j, analyzer);
    if (i < right) normalQuickSort(arr, i, right, analyzer);
}

// MergeSort optimizado con análisis de caché
template<typename Element>
void mergeWithAnalysis(vector<Element>& arr, int left, int mid, int right, 
                      vector<Element>& temp, CacheAnalyzer& analyzer) {
    int i = left, j = mid + 1, k = 0;
    
    // Fusionar los dos subarrays
    while (i <= mid && j <= right) {
        analyzer.memoryAccess(&arr[i]);
        analyzer.memoryAccess(&arr[j]);
        
        if (arr[i] <= arr[j]) {
            temp[k++] = move(arr[i++]);
        } else {
            temp[k++] = move(arr[j++]);
        }
    }
    
    // Copiar elementos restantes del primer subarray
    while (i <= mid) {
        analyzer.memoryAccess(&arr[i]);
        temp[k++] = move(arr[i++]);
    }
    
    // Copiar elementos restantes del segundo subarray
    while (j <= right) {
        analyzer.memoryAccess(&arr[j]);
        temp[k++] = move(arr[j++]);
    }
    
    // Copiar de vuelta al array original
    for (int idx = 0; idx < k; idx++) {
        arr[left + idx] = move(temp[idx]);
        analyzer.memoryAccess(&arr[left + idx]);
    }
}

template<typename Element>
void mergeSortWithAnalysis(vector<Element>& arr, int left, int right, 
                          vector<Element>& temp, CacheAnalyzer& analyzer) {
    if (left >= right) return;
    
    int mid = left + (right - left) / 2;
    mergeSortWithAnalysis(arr, left, mid, temp, analyzer);
    mergeSortWithAnalysis(arr, mid + 1, right, temp, analyzer);
    mergeWithAnalysis(arr, left, mid, right, temp, analyzer);
}

template<typename Element>
void mergeSortWithAnalysis(vector<Element>& arr, int left, int right, CacheAnalyzer& analyzer) {
    vector<Element> temp(arr.size());
    mergeSortWithAnalysis(arr, left, right, temp, analyzer);
}

// Generadores de datos de prueba mejorados
vector<int> generateRandomData(size_t size) {
    vector<int> data(size);
    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<> dis(1, 1000000);
    
    generate(data.begin(), data.end(), [&]() { return dis(gen); });
    return data;
}

vector<int> generateSortedData(size_t size) {
    vector<int> data(size);
    iota(data.begin(), data.end(), 0);
    return data;
}

vector<int> generateReverseSortedData(size_t size) {
    vector<int> data(size);
    iota(data.rbegin(), data.rend(), 0);
    return data;
}

// Función para mostrar resultados formateados
void printResults(const string& algorithm, const CacheAnalyzer& analyzer, 
                  long long duration, const string& dataType = "") {
    cout << "  " << algorithm;
    if (!dataType.empty()) {
        cout << " (" << dataType << ")";
    }
    cout << ":\n";
    cout << "    Accesos a memoria: " << analyzer.getMemoryAccessCount() << "\n";
    cout << "    Fallos de caché: " << analyzer.getCacheMisses() << "\n";
    cout << "    Tasa de aciertos: " << fixed << setprecision(2) 
              << (analyzer.getCacheHitRate() * 100) << "%\n";
    cout << "    Tiempo: " << duration << " μs\n";
}

// Probar diferentes tamaños de bloque de caché
void testDifferentCacheLineSizes(const vector<int>& data) {
    cout << "\n" << string(60, '=') << "\n";
    cout << "PRUEBA DE DIFERENTES TAMAÑOS DE LÍNEA DE CACHÉ\n";
    cout << string(60, '=') << "\n";
    
    vector<int> cache_sizes = {32, 64, 128, 256};
    
    for (int cache_line : cache_sizes) {
        CacheAnalyzer analyzer(cache_line);
        CacheAnalyzer optimal_analyzer(cache_line);
        vector<int> test_data = data;
        vector<int> bqs_test_data = data;

        cout << "\nLínea de caché: " << cache_line << " bytes\n";
        
        auto start = chrono::high_resolution_clock::now();
        normalQuickSort(test_data, 0, test_data.size() - 1, analyzer);
        auto end = chrono::high_resolution_clock::now();
        
        auto duration = chrono::duration_cast<chrono::microseconds>(end - start);
        
        printResults("QuickSort", analyzer, duration.count());

        start = chrono::high_resolution_clock::now();
        blockingQuickSort(bqs_test_data, 0, bqs_test_data.size() - 1, optimal_analyzer);
        end = chrono::high_resolution_clock::now();
        
        auto bqs_duration = chrono::duration_cast<chrono::microseconds>(end - start);
        
        printResults("BlockingQuickSort", optimal_analyzer, bqs_duration.count());
    }
}

int main() {
    cout << string(70, '=') << "\n";
    cout << "ANALIZADOR DE ACCESOS A MEMORIA EN ALGORITMOS DE ORDENAMIENTO\n";
    cout << string(70, '=') << "\n\n";
    
    // Probar con diferentes tamaños de dataset
    vector<size_t> dataset_sizes = {1000, 10000, 50000};
    
    for (size_t size : dataset_sizes) {
        cout << "\n" << string(40, '*') << "\n";
        cout << "TAMAÑO DEL DATASET: " << size << "\n";
        cout << string(40, '*') << "\n";
        
        // Generar datos
        auto random_data = generateRandomData(size);
        auto sorted_data = generateSortedData(size);
        auto reverse_data = generateReverseSortedData(size);
        
        vector<string> data_types = {"Aleatorios", "Ordenados", "Inversamente Ordenados"};
        vector<vector<int>> datasets = {random_data, sorted_data, reverse_data};
        int index = 0;

        for(vector<int> data : datasets){
            cout << "\n" << string(30, '-') << "\n";
            cout << "\nTIPO DE DATOS: " << data_types[index++] << "\n";
            cout << string(30, '-') << "\n";

            // Probar QuickSort normal
            CacheAnalyzer qs_analyzer;
            auto qs_data = data;
            auto start = chrono::high_resolution_clock::now();
            normalQuickSort(qs_data, 0, qs_data.size() - 1, qs_analyzer);
            auto end = chrono::high_resolution_clock::now();
            auto qs_duration = chrono::duration_cast<chrono::microseconds>(end - start);

            // Probar QuickSort optimizado
            CacheAnalyzer bqs_analyzer;
            auto bqs_data = data;
            start = chrono::high_resolution_clock::now();
            blockingQuickSort(bqs_data, 0, bqs_data.size() - 1, bqs_analyzer);
            end = chrono::high_resolution_clock::now();
            auto bqs_duration = chrono::duration_cast<chrono::microseconds>(end - start);
            
            // Probar MergeSort
            CacheAnalyzer ms_analyzer;
            auto ms_data = data;
            start = chrono::high_resolution_clock::now();
            mergeSortWithAnalysis(ms_data, 0, ms_data.size() - 1, ms_analyzer);
            end = chrono::high_resolution_clock::now();
            auto ms_duration = chrono::duration_cast<chrono::microseconds>(end - start);
            
            // Mostrar resultados
            printResults("QuickSort", qs_analyzer, qs_duration.count());
            cout << endl;
            printResults("BlockingQuickSort", bqs_analyzer, bqs_duration.count());
            cout << endl;
            printResults("MergeSort", ms_analyzer, ms_duration.count());
        }
        
    }
    
    // Probar diferentes tamaños de línea de caché
    // testDifferentCacheLineSizes(generateRandomData(50000));
    
    cout << "\n" << string(70, '=') << "\n";
    cout << "ANÁLISIS COMPLETADO EXITOSAMENTE\n";
    cout << string(70, '=') << "\n";
    
    return 0;
}