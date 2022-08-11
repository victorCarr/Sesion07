###################### SESIÓN 5: SERIES DE TIEMPO #######################
################################################################################
## EJEMPLO 1: CONEXIÓN ENTRE RSTUDIO Y GITHUB


################################################################################
## EJEMPLO 2: CONEXIÓN A UNA BDD CON R

# Comenzaremos instalando las librerias necesarias para realizar la conexion y 
# lectura de la base de datos en RStudio. Si previamente los tenias instalados 
# omite la instalacion, recuerda que solo necesitas realizarla una vez.

install.packages("DBI")
install.packages("RMySQL")

library(DBI)
library(RMySQL)

# Una vez que se tengan las librerias necesarias se procede a la lectura 
# (podrá ser que necesites otras, si te las solicita instalalas y cargalas). 
# De la base de datos de Shiny, la cual es un demo y nos permite interactuar con 
# este tipo de objetos. El comando dbConnect es el indicado para realizar la 
# lectura, los demás parámetros son los que nos dan acceso a la BDD.

MyDataBase <- dbConnect(
  drv = RMySQL::MySQL(),
  dbname = "shinydemo",
  host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
  username = "guest",
  password = "guest")

# Si no se arrojaron errores por parte de R, vamos a explorar la BDD

dbListTables(MyDataBase)

# Desplegar los campos o variables que contiene la tabla 
# City

dbListFields(MyDataBase, 'City')

# Consulta tipo MySQL

DataDB <- dbGetQuery(MyDataBase, "select * from City")

# El Objeto DataDB es un data frame pertenece a R
# y podemos aplicar los comandos usuales

class(DataDB)
head(DataDB)


pop.mean <- mean(DataDB$Population)  # Media a la variable de población
pop.mean 

pop.3 <- pop.mean *3   # Operaciones aritmeticas
pop.3

# Incluso podemos hacer usos de otros comandos de busqueda aplicando la 
# libreria dplyr

library(dplyr)
pop50.mex <-  DataDB %>% filter(CountryCode == "MEX" ,  Population > 50000)   # Ciudades del paÃ­s de MÃ©xico con mÃ¡s de 50,000 habitantes

head(pop50.mex)

unique(DataDB$CountryCode)   # Paises que contiene la BDD

# Nos desconectamos de la base de datos
dbDisconnect(MyDataBase)

################################################################################
## RETO 01: RSTUDIO CLOUD -> GITHUB

################################################################################
## EJEMPLO 3: VARIANTES EN LA LECTURA DE BDD CON R

# Ahora utilizaremos otra opcion para realizar queries a una BDD con la ayuda 
# de dplyr que sustituye a SELECT en MySQL y el operador %>%, hay que recordar 
# que con este comando tambienn podemos realizar busquedas de forma local.

# Comenzamos instalando las paqueterias necesarias y cargándolas a R

install.packages("pool")
install.packages("dbplyr")

library(dplyr)
library(pool)
library(dbplyr)

# Se realiza la lectura de la BDD con el comando dbPool, los demás parámetros 
# se siguen utilizando igual que el ejemplo anterior.

# La diferencia con el ejemplo anterior, es que en este caso no necesitamos 
# Guardar los datos en un objeto de R para manejar los datos.

my_db <- dbPool(
  RMySQL::MySQL(), 
  dbname = "shinydemo",
  host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
  username = "guest",
  password = "guest"
)

# Para ver el contenido de la BDD y realizar una búsqueda se procede de la 
# siguiente manera

dbListTables(my_db)

# Obtener los primeros 5 registros de Country

my_db %>% tbl("Country") %>% head(5) # library(dplyr)

# Obtener los primeros 5 registros de CountryLanguage

my_db %>% tbl("CountryLanguage") %>% head(5)

# Otra forma de generar una búsqueda sería con la libreria DBI, utilizando el 
# comando dbSendQuery

conn <- dbConnect(
  drv = RMySQL::MySQL(),
  dbname = "shinydemo",
  host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
  username = "guest",
  password = "guest")

rs <- dbSendQuery(conn, "SELECT * FROM City LIMIT 5;")

dbFetch(rs)

# Para finalizar nos desconectamos de la BDD

dbClearResult(rs)
dbDisconnect(conn)

################################################################################
## EJEMPLO 4: LECTURA DE ARCHIVOS JSON, XML Y TABLAS HTML

# Comenzaremos instalando los paquetes necesarios para despues cargarlos a R

install.packages("rjson")
library(rjson)

# Json
# Vamos a leer un archivo Json de prueba alojado aquí

URL <- "https://tools.learningcontainer.com/sample-json-file.json" # Asignando el link a una variable

JsonData <- fromJSON(file= URL)     # Se guarda el JSon en un objeto de R

class(JsonData)                     # Vemos que tipo de objeto es JsonData

str(JsonData)                       # Vemos la naturaleza de sus variables

# Finalmente ya que pudimos acceder al contenido del Json, tambien podemos 
# realizar la manipulacionn de los datos dentro del Json, por ejemplo:

sqrt(JsonData$Mobile)

# Para entrar a las demas variables recuerda que puedas usar el operador de $, 
# es decir, JsonData$

# XML
# Ahora vamos a leer datos XML en R, utilizando un archivo XML alojado aquí

# Lo primero es instalar y cargar el paquete XML y alojar el link
# en una variable para su lectura

install.packages("XML")
library(XML)

link <- "http://www-db.deis.unibo.it/courses/TW/DOCS/w3schools/xml/cd_catalog.xml"

# Analizando el XML desde la web
xmlfile <- xmlTreeParse(link)

# Ahora ya podemos ver las propiedades del objetvo xmlfile
summary(xmlfile)
head(xmlfile)

# Tambien gracias al xmlTreeParse podemos extraer los datos contenidos en el archivo

#Extraer los valores xml
topxml <- xmlSApply(xmlfile, function(x) xmlSApply(x, xmlValue))

# Colocandolos en un Data Frame
xml_df <- data.frame(t(topxml), row.names= NULL)

str(xml_df) # Observar la naturaleza de las variables del DF

# Convertiremos incluso las variables de PRICE y YEAR en datos numéricos para 
# poder realizar operaciones con este dato

xml_df$PRICE <- as.numeric(xml_df$PRICE) 
xml_df$YEAR <- as.numeric(xml_df$YEAR)

mean(xml_df$PRICE)
mean(xml_df$YEAR)

# Todo esto se puede realizar en un solo paso utilizando el siguiente comando
data_df <- xmlToDataFrame(link)
head(data_df)

# Tablas en HTML
# Comenzamos instalando el paquete rvest el cual nos permitirá realizar la 
# lectura de la tabla en el HTML

install.packages("rvest")
library(rvest)

# Introducimos una dirección URL donde se encuentre una tabla
theurl <- "https://solarviews.com/span/data2.htm"

file <- read_html(theurl)    # Leemos el html

# Selecciona pedazos dentro del HTML para identificar la tabla
tables <- html_nodes(file, "table")  

# Hay que analizar 'tables' para determinar cual es la posición en la lista 
# que contiene la tabla, en este caso es la no. 4

# Extraemos la tabla de acuerdo a la posición en la lista

table1 <- html_table(tables[4], fill = TRUE)

table <- na.omit(as.data.frame(table1))   # Quitamos NAN que meten filas extras 
# y convertimos la lista en un data frame para su manipulacion con R

str(table)  # Vemos la naturaleza de las variables

# Por ultimo realizamos una conversion de una columna tipo chr a num, se pueden 
# hacer las conversiones que se requieran
table$Albedo <- as.numeric(table$Albedo)
str(table)

################################################################################
## RETO 2: EXTRACCIÓN DE TABLAS EN UN HTML

################################################################################
## POSTWORK