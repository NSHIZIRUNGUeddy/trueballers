-- TRUE BALLERS: sample articles for demos/presentations.
-- Run this once in Supabase > SQL Editor after supabase/schema.sql.
-- Images live in public/sample/ and are served from /sample/<name>.jpg.
-- Safe to run again: rows are upserted by their fixed ids.

alter table public.articles add column if not exists views integer not null default 0;

insert into public.articles
  (id, author_id, title, excerpt, content, category, language, image_url, status, tags, published_at, views, created_at, updated_at)
values (
  '11111111-1111-4111-8111-111111111101',
  null,
  'Inside the next wave of Rwandan basketball talent',
  'A new generation of players is pushing the standard higher in Kigali and beyond, and coaches say the best is still ahead.',
  $t1$Rwandan basketball has never had more eyes on it. From packed school courts to the national league, a new generation of players is emerging with bigger goals and a sharper understanding of the game.

Coaches across Kigali say the biggest change is not just athleticism but preparation. Young players are training earlier, studying film, and taking strength and conditioning seriously. The result is a deeper pool of talent competing for places at every level.

The challenge now is turning that energy into a clear pathway. More competitive games, better coaching education, and consistent investment at grassroots level will decide how far this wave can go.

For now, the message from the court is simple: the next chapter of Rwandan basketball is already being written.$t1$,
  'Rwanda Basketball',
  'en',
  '/sample/rwanda-basketball.jpg',
  'published',
  array['Rwanda','Basketball','Development'],
  now() - interval '30 minutes',
  248,
  now() - interval '30 minutes',
  now() - interval '30 minutes'
)
on conflict (id) do update set
  title = excluded.title, excerpt = excluded.excerpt, content = excluded.content,
  category = excluded.category, language = excluded.language, image_url = excluded.image_url,
  status = excluded.status, tags = excluded.tags, published_at = excluded.published_at,
  views = excluded.views, updated_at = now();

insert into public.articles
  (id, author_id, title, excerpt, content, category, language, image_url, status, tags, published_at, views, created_at, updated_at)
values (
  '11111111-1111-4111-8111-111111111102',
  null,
  'RBL title race heats up as contenders find their rhythm',
  'The Rwanda Basketball League is tightening at the top, with every possession now carrying extra weight.',
  $t2$The Rwanda Basketball League has reached the part of the season where small details decide big outcomes. Contenders are separated by a handful of possessions, and every rotation, timeout, and defensive stand is being scrutinised.

What stands out is the balance across the league. Teams that once relied on one scorer are now sharing the ball, spacing the floor, and making opponents work on both ends. The result has been a run of close games that have brought crowds back to the gym.

Coaches are warning against complacency. With fixtures coming quickly, recovery and discipline matter as much as tactics. The teams that stay healthy and focused through the next stretch will give themselves the best chance in the closing weeks.

The title race is far from settled, and that is exactly what makes it worth watching.$t2$,
  'Rwanda Basketball League',
  'en',
  '/sample/rwanda-basketball-league.jpg',
  'published',
  array['Rwanda','RBL','League'],
  now() - interval '2 hours',
  186,
  now() - interval '2 hours',
  now() - interval '2 hours'
)
on conflict (id) do update set
  title = excluded.title, excerpt = excluded.excerpt, content = excluded.content,
  category = excluded.category, language = excluded.language, image_url = excluded.image_url,
  status = excluded.status, tags = excluded.tags, published_at = excluded.published_at,
  views = excluded.views, updated_at = now();

insert into public.articles
  (id, author_id, title, excerpt, content, category, language, image_url, status, tags, published_at, views, created_at, updated_at)
values (
  '11111111-1111-4111-8111-111111111103',
  null,
  'BAL keeps raising the bar for African club basketball',
  'The Basketball Africa League has become a genuine stage for the continent''s best clubs, players, and coaches.',
  $t3$The Basketball Africa League has quickly become one of the most important stages in African sport. For clubs, it offers a level of competition and exposure that is difficult to find anywhere else on the continent.

The growth is visible in the quality of play. Teams are arriving better prepared, with deeper rosters and more sophisticated scouting. Games are being decided by execution, not just talent, and the standard rises with every edition.

For players, the league is a bridge. It connects local success to international opportunity, and it gives young fans at home a clear picture of what elite basketball looks like.

The BAL still has room to grow, but its direction is clear: upward.$t3$,
  'BAL',
  'en',
  '/sample/bal.jpg',
  'published',
  array['BAL','Africa','Club Basketball'],
  now() - interval '4 hours',
  312,
  now() - interval '4 hours',
  now() - interval '4 hours'
)
on conflict (id) do update set
  title = excluded.title, excerpt = excluded.excerpt, content = excluded.content,
  category = excluded.category, language = excluded.language, image_url = excluded.image_url,
  status = excluded.status, tags = excluded.tags, published_at = excluded.published_at,
  views = excluded.views, updated_at = now();

insert into public.articles
  (id, author_id, title, excerpt, content, category, language, image_url, status, tags, published_at, views, created_at, updated_at)
values (
  '11111111-1111-4111-8111-111111111104',
  null,
  'Patriots building for another deep run',
  'Patriots are taking a patient approach to the season, and the results are starting to follow.',
  $t4$Patriots have built their recent success on identity. They defend with discipline, rebound with purpose, and trust their half-court execution when games slow down.

This season has demanded patience. New faces have needed time to settle, and the coaching staff has used the early weeks to test combinations and build chemistry. The signs are encouraging.

What has impressed most is the team's ability to stay composed. In close games, Patriots have found extra possessions through hustle and smart decisions, the kind of details that matter in the playoffs.

The goal is not to peak early. It is to be at their best when the games carry the most weight.$t4$,
  'Patriots',
  'en',
  '/sample/patriots.jpg',
  'published',
  array['Patriots','Rwanda','Team'],
  now() - interval '7 hours',
  154,
  now() - interval '7 hours',
  now() - interval '7 hours'
)
on conflict (id) do update set
  title = excluded.title, excerpt = excluded.excerpt, content = excluded.content,
  category = excluded.category, language = excluded.language, image_url = excluded.image_url,
  status = excluded.status, tags = excluded.tags, published_at = excluded.published_at,
  views = excluded.views, updated_at = now();

insert into public.articles
  (id, author_id, title, excerpt, content, category, language, image_url, status, tags, published_at, views, created_at, updated_at)
values (
  '11111111-1111-4111-8111-111111111105',
  null,
  'REG''s defensive identity powers title push',
  'REG are winning with stops, not just shots, and opponents are finding it hard to settle into rhythm.',
  $t5$REG have made defence their calling card this season. They pressure the ball, shrink driving lanes, and make opponents earn every basket.

That approach has travelled well. Even on nights when the offence has been uneven, REG have stayed in games by controlling the glass and forcing turnovers. It is a formula that holds up when the pace slows.

The next step is consistency on the other end. When REG move the ball and attack the rim with purpose, they look like one of the most complete teams in the league.

If the defensive standard holds, REG will be a difficult matchup for anyone.$t5$,
  'REG',
  'en',
  '/sample/reg.jpg',
  'published',
  array['REG','Rwanda','Defence'],
  now() - interval '1 day',
  143,
  now() - interval '1 day',
  now() - interval '1 day'
)
on conflict (id) do update set
  title = excluded.title, excerpt = excluded.excerpt, content = excluded.content,
  category = excluded.category, language = excluded.language, image_url = excluded.image_url,
  status = excluded.status, tags = excluded.tags, published_at = excluded.published_at,
  views = excluded.views, updated_at = now();

insert into public.articles
  (id, author_id, title, excerpt, content, category, language, image_url, status, tags, published_at, views, created_at, updated_at)
values (
  '11111111-1111-4111-8111-111111111106',
  null,
  'APR leaning on youth as the new season takes shape',
  'APR are giving young players real minutes, and the early returns suggest the gamble is paying off.',
  $t6$APR have always been associated with experience, but this season the club is investing in youth. Young players are being trusted with meaningful minutes, and they are repaying that faith with energy and confidence.

The adjustment has not always been smooth. There have been moments of inconsistency, as expected with a younger rotation. But the improvement from game to game has been clear.

Senior players have played an important role, setting the standard in training and helping the newcomers understand what it takes to compete at this level.

APR are building for more than one season. The early signs suggest the foundation is solid.$t6$,
  'APR',
  'en',
  '/sample/apr.jpg',
  'published',
  array['APR','Rwanda','Youth'],
  now() - interval '1 day 4 hours',
  121,
  now() - interval '1 day 4 hours',
  now() - interval '1 day 4 hours'
)
on conflict (id) do update set
  title = excluded.title, excerpt = excluded.excerpt, content = excluded.content,
  category = excluded.category, language = excluded.language, image_url = excluded.image_url,
  status = excluded.status, tags = excluded.tags, published_at = excluded.published_at,
  views = excluded.views, updated_at = now();

insert into public.articles
  (id, author_id, title, excerpt, content, category, language, image_url, status, tags, published_at, views, created_at, updated_at)
values (
  '11111111-1111-4111-8111-111111111107',
  null,
  'Women''s League stars set the pace in Rwanda',
  'The Women''s League is producing some of the most watchable basketball in the country right now.',
  $t7$The Women's League has become one of the most competitive and entertaining competitions in Rwandan basketball. The pace is quick, the skill level is high, and the margin for error is small.

Teams are increasingly built around movement and shooting, with bigs who can pass and guards who can pressure for full possessions. That style has produced games that are easy to watch and hard to predict.

Off the court, the visibility of the league continues to grow. More fans are following the teams, and more young girls are finding players they can look up to.

The standard is rising, and the league is earning the attention it is getting.$t7$,
  'Women''s League',
  'en',
  '/sample/womens-league.jpg',
  'published',
  array['Women''s Basketball','Rwanda','League'],
  now() - interval '2 days',
  207,
  now() - interval '2 days',
  now() - interval '2 days'
)
on conflict (id) do update set
  title = excluded.title, excerpt = excluded.excerpt, content = excluded.content,
  category = excluded.category, language = excluded.language, image_url = excluded.image_url,
  status = excluded.status, tags = excluded.tags, published_at = excluded.published_at,
  views = excluded.views, updated_at = now();

insert into public.articles
  (id, author_id, title, excerpt, content, category, language, image_url, status, tags, published_at, views, created_at, updated_at)
values (
  '11111111-1111-4111-8111-111111111108',
  null,
  'NBA storylines basketball fans in Rwanda should follow',
  'From rising stars to tactical trends, here are the NBA themes worth watching this season.',
  $t8$The NBA never stops moving. Every season brings new stars, new schemes, and new debates, and this one is no different.

One of the most interesting storylines is the way teams are balancing size and spacing. Lineups are getting more flexible, and the best teams are finding ways to defend without sacrificing shooting.

Young players are also making noise. A new generation is taking on bigger roles earlier, and their development is reshaping the competitive picture across both conferences.

For fans in Rwanda, the time difference makes the league a morning and weekend habit. The games are worth setting the alarm for.$t8$,
  'NBA',
  'en',
  '/sample/nba.jpg',
  'published',
  array['NBA','International','Analysis'],
  now() - interval '2 days 6 hours',
  389,
  now() - interval '2 days 6 hours',
  now() - interval '2 days 6 hours'
)
on conflict (id) do update set
  title = excluded.title, excerpt = excluded.excerpt, content = excluded.content,
  category = excluded.category, language = excluded.language, image_url = excluded.image_url,
  status = excluded.status, tags = excluded.tags, published_at = excluded.published_at,
  views = excluded.views, updated_at = now();

insert into public.articles
  (id, author_id, title, excerpt, content, category, language, image_url, status, tags, published_at, views, created_at, updated_at)
values (
  '11111111-1111-4111-8111-111111111109',
  null,
  'FIBA windows and what they mean for African basketball',
  'International windows are shaping national teams, and African programmes are learning how to use them better.',
  $t9$FIBA windows have changed the rhythm of international basketball. Instead of long camps, national teams now work in shorter bursts, with players arriving from different leagues and systems.

For African programmes, that presents a challenge and an opportunity. The challenge is building chemistry quickly. The opportunity is exposing more players to international competition and widening the talent pool.

Federations that plan well are already seeing the benefits. Clear roles, consistent selection, and a shared style of play matter more than ever.

The windows are not perfect, but they are helping African basketball grow in a more structured way.$t9$,
  'FIBA',
  'en',
  '/sample/fiba.jpg',
  'published',
  array['FIBA','Africa','International'],
  now() - interval '3 days',
  168,
  now() - interval '3 days',
  now() - interval '3 days'
)
on conflict (id) do update set
  title = excluded.title, excerpt = excluded.excerpt, content = excluded.content,
  category = excluded.category, language = excluded.language, image_url = excluded.image_url,
  status = excluded.status, tags = excluded.tags, published_at = excluded.published_at,
  views = excluded.views, updated_at = now();

insert into public.articles
  (id, author_id, title, excerpt, content, category, language, image_url, status, tags, published_at, views, created_at, updated_at)
values (
  '11111111-1111-4111-8111-111111111110',
  null,
  'EuroLeague nights and why the elite competition matters',
  'The EuroLeague offers a different kind of basketball: precise, physical, and tactically demanding.',
  $t10$The EuroLeague is one of the purest tests in club basketball. The pace is controlled, the spacing is precise, and every possession feels like a chess move.

That style has made the competition a favourite for coaches and serious fans. Teams must defend together, execute half-court sets, and adapt to opponents who know their tendencies inside out.

For players outside Europe, the league is also a reference point. It shows how far disciplined fundamentals and team structure can take a group.

EuroLeague nights may arrive late in Rwanda, but the basketball is worth the wait.$t10$,
  'EuroLeague',
  'en',
  '/sample/euroleague.jpg',
  'published',
  array['EuroLeague','Europe','Analysis'],
  now() - interval '4 days',
  134,
  now() - interval '4 days',
  now() - interval '4 days'
)
on conflict (id) do update set
  title = excluded.title, excerpt = excluded.excerpt, content = excluded.content,
  category = excluded.category, language = excluded.language, image_url = excluded.image_url,
  status = excluded.status, tags = excluded.tags, published_at = excluded.published_at,
  views = excluded.views, updated_at = now();

insert into public.articles
  (id, author_id, title, excerpt, content, category, language, image_url, status, tags, published_at, views, created_at, updated_at)
values (
  '11111111-1111-4111-8111-111111111111',
  null,
  'Watch: the week''s best basketball highlights',
  'Dunks, dimes, and clutch shots: a quick round-up of the moments that lit up the court this week.',
  $t11$Every week brings a new set of highlights, and this one did not disappoint. There were open-court finishes, late-game buckets, and defensive plays that changed momentum in an instant.

The best moments came when teams shared the ball. Extra passes created open looks, and unselfish play turned good possessions into great ones.

There was also no shortage of individual skill. Guards created space off the dribble, bigs finished through contact, and shooters punished defenders who went under screens.

Watch the clips, then tell us which moment was your favourite.$t11$,
  'Videos',
  'en',
  '/sample/videos.jpg',
  'published',
  array['Videos','Highlights','Basketball'],
  now() - interval '5 days',
  421,
  now() - interval '5 days',
  now() - interval '5 days'
)
on conflict (id) do update set
  title = excluded.title, excerpt = excluded.excerpt, content = excluded.content,
  category = excluded.category, language = excluded.language, image_url = excluded.image_url,
  status = excluded.status, tags = excluded.tags, published_at = excluded.published_at,
  views = excluded.views, updated_at = now();

insert into public.articles
  (id, author_id, title, excerpt, content, category, language, image_url, status, tags, published_at, views, created_at, updated_at)
values (
  '11111111-1111-4111-8111-111111111112',
  null,
  'Why Rwanda''s basketball future depends on the grassroots',
  'Talent is everywhere in Rwanda. The next step is building the structures that help it grow.',
  $t12$Rwanda has no shortage of basketball talent. Walk into any neighbourhood court and you will find players with footwork, flair, and a genuine love for the game.

The bigger question is how to support that talent. Grassroots programmes need consistent coaching, safe facilities, and regular competition. Without those foundations, potential can go unnoticed.

Schools have a major role to play. A strong school competition gives young players structure, teaches discipline, and creates a route into club basketball. Coaches need support too, through education and mentorship.

The national team will only be as strong as the base beneath it. Investing in grassroots basketball is not a short-term project. It is the most important long-term decision the sport can make.$t12$,
  'Opinion',
  'en',
  '/sample/opinion.jpg',
  'published',
  array['Opinion','Grassroots','Rwanda'],
  now() - interval '6 days',
  96,
  now() - interval '6 days',
  now() - interval '6 days'
)
on conflict (id) do update set
  title = excluded.title, excerpt = excluded.excerpt, content = excluded.content,
  category = excluded.category, language = excluded.language, image_url = excluded.image_url,
  status = excluded.status, tags = excluded.tags, published_at = excluded.published_at,
  views = excluded.views, updated_at = now();
