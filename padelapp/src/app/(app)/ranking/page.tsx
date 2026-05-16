import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { mockRanking, mockCurrentUserRanking, mockReputation, mockReputationRanking } from "@/lib/mock-data";

export default function RankingPage() {
  return (
    <div className="flex flex-col gap-6">
      <header className="space-y-2">
        <h1 className="text-2xl font-bold">Ranking & reputación</h1>
        <p className="text-sm text-muted-foreground">
          Puntos actualizados con decay mensual, categorías 1-8 y reputación por asistencia.
        </p>
      </header>

      {mockCurrentUserRanking.hasPosition ? (
        <Card className="bg-primary/5 border-primary/20">
          <CardHeader className="flex items-center justify-between space-y-0">
            <div>
              <CardTitle className="text-base font-semibold">
                Tu posición: #{mockCurrentUserRanking.position}
              </CardTitle>
              <CardDescription>
                {mockCurrentUserRanking.points} pts · Nivel {mockCurrentUserRanking.level}
              </CardDescription>
            </div>
            <Badge variant="default">{mockCurrentUserRanking.trend}</Badge>
          </CardHeader>
        </Card>
      ) : (
        <Card className="bg-muted/50">
          <CardHeader>
            <CardTitle className="text-base">Aún sin posición</CardTitle>
            <CardDescription>
              Jugá tu primer partido para entrar al ranking.
            </CardDescription>
          </CardHeader>
        </Card>
      )}

      <Tabs defaultValue="individual" className="w-full">
        <TabsList>
          <TabsTrigger value="individual">Individual</TabsTrigger>
          <TabsTrigger value="parejas">Parejas</TabsTrigger>
          <TabsTrigger value="reputacion">Reputación</TabsTrigger>
        </TabsList>
        <TabsContent value="individual" className="space-y-3">
          {mockRanking.map((player) => (
            <Card key={player.position}>
              <CardHeader className="flex items-center justify-between space-y-0">
                <div>
                  <CardTitle className="text-base font-semibold">
                    {player.position}. {player.name}
                  </CardTitle>
                  <CardDescription>
                    Nivel {player.level} · {player.points} pts
                  </CardDescription>
                </div>
                <Badge variant="outline">{player.trend}</Badge>
              </CardHeader>
            </Card>
          ))}
        </TabsContent>
        <TabsContent value="parejas" className="space-y-3">
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Aún sin datos</CardTitle>
              <CardDescription>
                Cuando registres partidos con pareja fija verás su evolución aquí.
              </CardDescription>
            </CardHeader>
          </Card>
        </TabsContent>
        <TabsContent value="reputacion" className="space-y-6">
          <Card className="bg-primary/5 border-primary/20">
            <CardHeader>
              <CardTitle className="text-base">Tu Reputación</CardTitle>
              <CardDescription>Basada en tu asistencia y cumplimiento.</CardDescription>
            </CardHeader>
            <CardContent className="flex items-center justify-between">
              <div className="flex flex-col">
                <span className="text-4xl font-black text-primary">{mockReputation.score}</span>
                <span className="text-xs text-muted-foreground">reputation score</span>
              </div>
              <div className="text-right space-y-1">
                <p className="text-sm font-medium">{mockReputation.attendanceRate} asistencia</p>
                <p className="text-xs text-muted-foreground">{mockReputation.matchesConfirmed} partidos · {mockReputation.noShows} no-show</p>
              </div>
            </CardContent>
          </Card>

          <div className="space-y-3">
            <h3 className="text-sm font-semibold text-muted-foreground uppercase px-1">Top Reputación</h3>
            {mockReputationRanking.map((player) => (
              <Card key={player.position}>
                <CardHeader className="flex items-center justify-between space-y-0">
                  <div>
                    <CardTitle className="text-base font-semibold">
                      {player.position}. {player.name}
                    </CardTitle>
                    <CardDescription>
                      {player.matches} partidos confirmados
                    </CardDescription>
                  </div>
                  <div className="text-right">
                    <span className="text-lg font-bold text-primary">{player.score}%</span>
                  </div>
                </CardHeader>
              </Card>
            ))}
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}
