------------------------------------------------------------------------------------------------------------------------------------------
-- Sestini (obtém 3 recomendações de produtos baseando-se na categoria do último produto visitado nas últimas 24 horas)
------------------------------------------------------------------------------------------------------------------------------------------

-- Exibe as recomendações, porém sem exibir nada do produto visitado

SELECT TOP 3 S.ProductName, S.ImageUrlBig, CONCAT('https://www.sestini.com.br', S.DetailUrl) AS DetailUrl, 
FORMAT(S.Price, 'C2', 'pt-BR') AS Price, FORMAT(S.ListPrice, 'C2', 'pt-BR') as ListPrice, IIF(S.ListPrice > S.Price, 1, 0) AS Mostra, CategoryId
FROM dt_Sku AS S
INNER JOIN dt_Product AS P ON S.ProductId = P.ProductId
WHERE P.CategoryId = (
    SELECT TOP 1 P.CategoryId FROM dt_WebModule_WebsiteVisits AS WV
    JOIN dt_Product AS P ON WV.ProductId = P.ProductId
    WHERE Email = @email AND
    DATEDIFF(DAY, WV.Date, GETDATE()) <= 1
    ORDER BY Date DESC
  )
AND
S.IsActive = 'true'
ORDER BY NEWID()

------------------------------------------------------------------------------------------------------------------------------------------

-- Exibe dados tanto do produto visitado quanto dos produtos recomendados
-- Dados do produto visitado saem da query interna pra externa via JOIN com SELECT

SELECT TOP 3 S.ProductName AS RecomProductName, S.ImageUrlBig AS RecomImageUrlBig, 
CONCAT('https://www.sestini.com.br', S.DetailUrl) AS RecomDetailUrl, FORMAT(S.Price, 'C2', 'pt-BR') AS RecomPrice, 
FORMAT(S.ListPrice, 'C2', 'pt-BR') AS RecomListPrice, IIF(S.ListPrice > S.Price, 1, 0) AS RecomMostra, WV.ProductName AS VisitedProduct, 
WV.ProductUrl AS VisitedProductUrl, WV.ProductImageUrl AS VisitedProductImage, FORMAT(WV.ProductPrice, 'C2', 'pt-BR') AS VisitedProductPrice, 
P.CategoryId
FROM dt_Sku AS S
INNER JOIN dt_Product AS P ON S.ProductId = P.ProductId
INNER JOIN (
    SELECT TOP 1 WV.ProductName, WV.ProductUrl, WV.ProductImageUrl, WV.ProductPrice, P.CategoryId
    FROM dt_WebModule_WebsiteVisits AS WV
    INNER JOIN dt_Product AS P ON WV.ProductId = P.ProductId
    WHERE WV.Email = @email
    AND DATEDIFF(DAY, WV.Date, GETDATE()) <= 1
    ORDER BY WV.Date DESC
) AS WV ON P.CategoryId = WV.CategoryId
WHERE S.IsActive = 'true'
ORDER BY NEWID()

------------------------------------------------------------------------------------------------------------------------------------------

-- Exibe dados tanto do produto visitado quanto dos produtos recomendados
-- Dados do produto visitado saem da query interna pra externa via CROSS APPLY

SELECT TOP 3 S.ProductName AS RecomProductName, S.ImageUrlBig AS RecomImageUrlBig, 
CONCAT('https://www.sestini.com.br', S.DetailUrl) AS RecomDetailUrl, FORMAT(S.Price, 'C2', 'pt-BR') AS RecomPrice, 
FORMAT(S.ListPrice, 'C2', 'pt-BR') AS RecomListPrice, IIF(S.ListPrice > S.Price, 1, 0) AS RecomMostra, WV.ProductName AS VisitedProduct, 
WV.ProductUrl AS VisitedProductUrl, WV.ProductImageUrl AS VisitedProductImage, FORMAT(WV.ProductPrice, 'C2', 'pt-BR') AS VisitedProductPrice, 
P.CategoryId
FROM dt_Sku AS S
INNER JOIN dt_Product AS P ON S.ProductId = P.ProductId
CROSS APPLY (
    SELECT TOP 1 WV.ProductName, WV.ProductUrl, WV.ProductImageUrl, WV.ProductPrice, P.CategoryId 
    FROM dt_WebModule_WebsiteVisits AS WV
    JOIN dt_Product AS P ON WV.ProductId = P.ProductId
    WHERE WV.Email = @email AND
    DATEDIFF(DAY, WV.Date, GETDATE()) <= 1
    ORDER BY WV.Date DESC
) AS WV
WHERE P.CategoryId = WV.CategoryId
AND S.IsActive = 'true'
ORDER BY NEWID()

/*

<var products="GetRowsByTemplate('getThreeRecomendations', new [] { new Param('email', SubscriberEmail) })"/>

<if condition="products.Count > 0">
  <p>Olá senhorito(a)</p>
  <p>Você visitou este nosso produto nas últimas 24 horas</p>
  <ul>
    <li>Nome: ${products[0]['VisitedProductName']}</li>
    <li>URL: ${products[0]['VisitedProductUrl']}</li>
    <li>Imagem: ${products[0]['VisitedProductImage']}</li>
    <li>Preço: ${products[0]['VisitedProductPrice']}</li>
  </ul>
  
  <p>Sendo assim, receba 3 recomendações de novos produtos da mesma categoria</p>
  
  <h3>Recomendação 1</h3>
  
  <p>Nome: ${products[0]['RecomProductName']}</p>
  <p>Imagem: ${products[0]['RecomImageUrlBig']}</p>
  <p>URL: ${products[0]['RecomDetailUrl']}</p>
  <p>Preço original: ${products[0]['RecomListPrice']}</p>
  <p>Preço com desconto: ${products[0]['RecomPrice']}</p>
  
  <h3>Recomendação 2</h3>
  
  <p>Nome: ${products[1]['RecomProductName']}</p>
  <p>Imagem: ${products[1]['RecomImageUrlBig']}</p>
  <p>URL: ${products[1]['RecomDetailUrl']}</p>
  <p>Preço original: ${products[1]['RecomListPrice']}</p>
  <p>Preço com desconto: ${products[1]['RecomPrice']}</p>
  
  <h3>Recomendação 3</h3>
  
  <p>Nome: ${products[2]['RecomProductName']}</p>
  <p>Imagem: ${products[2]['RecomImageUrlBig']}</p>
  <p>URL: ${products[2]['RecomDetailUrl']}</p>
  <p>Preço original: ${products[2]['RecomListPrice']}</p>
  <p>Preço com desconto: ${products[2]['RecomPrice']}</p>
</if>



*/
