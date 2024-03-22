---- changing table name
EXEC sp_rename 'all_seasons$', 'nba_information'


---- exploring general averages


-- avg age in the nba
SELECT FLOOR(AVG(age)) AvgAge
FROM nba_information
-- avg height in the nba
SELECT FLOOR(AVG(player_height)) AvgHeight
FROM nba_information
-- avg weight in the nba
SELECT FLOOR(AVG(player_weight)) AvgWeight
FROM nba_information
-- avg points
SELECT ROUND(AVG(pts), 1) AvgPoints
FROM nba_information
WHERE pts <> 0
-- avg assists
SELECT ROUND(AVG(ast), 1) AvgAssists
FROM nba_information
WHERE ast <> 0
-- avg rebounds
SELECT ROUND(AVG(reb), 1) AvgRebounds
FROM nba_information
WHERE reb <> 0


---- exploring lowest and highest values


-- oldest nba player
SELECT player_name, age
FROM nba_information
WHERE age = (
              SELECT MAX(age) FROM nba_information
			   )
-- youngest nba player
SELECT player_name, age
FROM nba_information
WHERE age = (
              SELECT MIN(age) FROM nba_information
			   )
-- tallest nba player
SELECT DISTINCT player_name, player_height
FROM nba_information
WHERE player_height = (
                        SELECT MAX(player_height) FROM nba_information
						)
-- shortest nba player
SELECT DISTINCT player_name, player_height
FROM nba_information
WHERE player_height = (
                        SELECT MIN(player_height) FROM nba_information
						)
-- heaviest nba player
SELECT player_name, ROUND(player_weight, 2)
FROM nba_information
WHERE player_weight = (
                        SELECT MAX(player_weight) FROM nba_information
						)
-- lightest nba player
SELECT DISTINCT player_name, ROUND(player_weight, 2)
FROM nba_information
WHERE player_weight = (
                        SELECT MIN(player_weight) FROM nba_information
						)


---- 


-- number of players that went to college
SELECT COUNT(*)
FROM nba_information
WHERE college <> 'None'
-- number of players did not go to college
SELECT COUNT(*)
FROM nba_information
WHERE college = 'None'


----


-- highest average season points 
SELECT TOP 20 team_abbreviation, player_name, season, MAX(pts) AvgPoints
FROM nba_information
GROUP BY team_abbreviation, player_name, season
HAVING   MAX(pts) <> 0
ORDER BY AvgPoints DESC
-- highest average season assists
SELECT TOP 20 team_abbreviation, player_name, season, MAX(ast) AvgPoints
FROM nba_information
GROUP BY team_abbreviation, player_name, season
HAVING   MAX(ast) <> 0
ORDER BY AvgPoints DESC


---- average points per season


SELECT season, ROUND(AVG(pts), 1) AvgPointsPerSeason
FROM nba_information
GROUP BY season
ORDER BY AvgPointsPerSeason DESC

---- best 10 scorers
-- all nationalities
SELECT TOP 10 pts, player_name, team_abbreviation, country
FROM nba_information
GROUP BY pts, player_name, team_abbreviation, country
ORDER BY pts DESC
-- best 10 non US scorers
SELECT TOP 10 pts, player_name, team_abbreviation, country
FROM nba_information
WHERE country <> 'USA'
ORDER BY pts DESC


---- top 50 long-tenured players who consistently maintain a positive net rating


SELECT player_name, team_abbreviation, ROUND(AVG(net_rating), 1) AvgNetRating, COUNT(season) SeasonsPlayed
FROM nba_information
WHERE gp > 40
GROUP BY player_name, team_abbreviation
HAVING COUNT(season) > 7 AND AVG(net_rating) > 0
ORDER BY AvgNetRating DESC


---- player distribution by country


SELECT country, COUNT(DISTINCT player_name) NumberOfPlayers
FROM nba_information
GROUP BY country	
ORDER BY NumberOfPlayers DESC


---- 
-- Top 10 players by points (pts)
SELECT TOP 10 player_name, pts
FROM nba_information
ORDER BY pts DESC
-- Top 10 players by rebounds (reb)
SELECT TOP 10 player_name, reb
FROM nba_information
ORDER BY reb DESC
-- Top 10 players by assists (ast)
SELECT TOP 10 player_name, ast
FROM nba_information
ORDER BY ast DESC


---- player's overall impact on the game 


SELECT player_name, 
      ROUND((pts + reb + ast)/gp, 3) AS PER
FROM nba_information
WHERE gp > 40
ORDER BY PER DESC


----
-- average points scored by each team
SELECT team_abbreviation, ROUND(AVG(pts), 1) AveragePointsPerTeam
FROM nba_information
GROUP BY team_abbreviation
ORDER BY AveragePointsPerTeam DESC

-- average rebounds per game by each team
SELECT team_abbreviation, ROUND(AVG(reb), 3) AvgRebounds
FROM nba_information
GROUP BY team_abbreviation
ORDER BY AvgRebounds DESC




