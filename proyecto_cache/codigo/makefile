#compilador
CXX = g++
CXXFLAGS = -Wall -g -O2

#nombre del ejecutable
TARGET = proyectoCache

#define los archivos fuente (.cpp) que se compilarán
SRCS = proyectoCache.cpp
# Genera automáticamente la lista de archivos objeto (.o) a partir de los fuentes (.cpp)
OBJS = $(SRCS:.cpp=.o)		

# Regla por defecto: compilar el ejecutable
all: $(TARGET)	
# Regla para construir el ejecutable
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $(TARGET)

# Regla para compilar archivos .cpp en .o
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@	
# Regla para limpiar los archivos generados
clean:
	rm -f $(OBJS) $(TARGET)		
# Marca 'all' y 'clean' como objetivos "ficticios" (no son archivos reales)
.PHONY: all clean		
