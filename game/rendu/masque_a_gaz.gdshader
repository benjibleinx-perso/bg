// CE QU'ON VOIT QUAND ON PORTE LE MASQUE A GAZ.
//
// « L'effet masque est sympa mais il faudra l'accentuer BEAUCOUP plus. Faire en
// sorte que ce soit beaucoup plus difficile d'y voir quoi que ce soit. Rajouter
// un effet "low shutter" comme si le personnage etait sonne. » — retour du
// 23/08/2026.
//
// CE QUI A CHANGE, ET POURQUOI LE PREMIER REGLAGE ETAIT DEFENDABLE. Le script
// disait « vision LEGEREMENT filtree », et le garde-fou d'alors etait qu'il
// faut voir les deux corps a l'arriere. Le retour supprime les deux : la vision
// doit etre « trouble et ILLISIBLE, on ne sait pas ou on est, ni ou on va
// vraiment », et regarder les corps sort du suivi de mission. Le joueur ne
// cherche plus rien a l'ecran — il suit une VOIX.
//
// ON LIT L'ECRAN, MAINTENANT, ET C'EST UN REVIREMENT ASSUME.
//
// La version d'avant s'y refusait, mesure a l'appui : hint_screen_texture coute
// +4,3 ms par image sur ce projet (voir liquide.gdshader). Elle obtenait donc
// le RESSENTI du « low shutter » sans optique — un champ tres ferme, une
// respiration ample, un battement qui mange l'image par vagues — et elle
// l'ecrivait noir sur blanc : « le low shutter n'est pas simule optiquement ».
//
// Le retour du 27/08/2026 refuse exactement ce compromis :
//
//   « Est-ce possible de reellement creer un flou de mouvement/vision trouble.
//     L'effet "low shutter". Je trouve que ca manque. A l'heure actuelle, tu as
//     surtout plus opacifie le filtre vert du masque. J'aimerais surtout un
//     effet plus flou de mouvement si c'est possible. »
//
// Il a raison, et la note technique ne repond pas a son objection : opacifier
// n'est pas flouter. Ce que le cout change, c'est OU on le paie — et ici il se
// paie sur la premiere minute du jeu, la seule ou ce filtre existe, pas sur les
// vingt heures qui suivent. Un budget d'image se defend a l'echelle de la
// scene, pas du shader.
//
// LE FLOU SUIT LE MOUVEMENT REEL. `derive` est pousse par systemes/
// filtre_ecran.gd : c'est de combien l'image a bouge depuis la derniere image,
// en UV. On echantillonne le long de ce vecteur — c'est un obturateur lent, au
// sens propre : le capteur integre ce qui a defile pendant la pose.
shader_type canvas_item;
render_mode blend_mix, unshaded;

// L'IMAGE DEJA RENDUE, c'est-a-dire le monde et rien d'autre : ce calque est
// pose SOUS le HUD, donc l'interface n'entre pas dans la copie et ne sera pas
// floue. « Le masque filtre le monde, pas l'interface. »
uniform sampler2D ecran : hint_screen_texture, filter_linear_mipmap;

// DE COMBIEN L'IMAGE A BOUGE, en UV, sur la derniere image. Pousse par le
// systeme ; a zero, il ne reste que le trouble.
uniform vec2 derive = vec2(0.0);

// LE FLOU QUI RESTE QUAND ON NE BOUGE PAS. « La vision est trouble et
// illisible » : un masque a gaz raye et embue ne redevient pas net parce qu'on
// s'arrete. En UV, donc independant de la resolution.
uniform float trouble : hint_range(0.0, 0.02) = 0.004;

// COMBIEN D'ECHANTILLONS. Six : en dessous la trainee se lit comme des images
// fantomes separees, au-dessus on paie sans que ca se voie. C'est une boucle a
// pas fixe, deroulee par le compilateur.
const int PRISES = 6;

// La teinte du verre. Legerement verte et desaturee : c'est du polycarbonate
// teinte, pas une lunette de vision nocturne.
//
// PLUS SOMBRE QU'AVANT, et pour une raison qui a change : la scene se joue
// desormais de JOUR — « la mission doit imperativement se derouler la
// journee ». Une teinte reglee pour une nuit noire devient transparente sous un
// soleil de fin d'apres-midi.
uniform vec4 teinte : source_color = vec4(0.22, 0.29, 0.24, 1.0);

// Ce qu'on voit dans le coin de l'oeil, c'est-a-dire plus rien du tout.
uniform vec4 bordure : source_color = vec4(0.02, 0.03, 0.03, 0.99);

// Opacite de la teinte AU CENTRE.
//
// 0.40 avant, sur l'idee qu'il fallait pouvoir jouer. C'est justement ce que le
// retour refuse : « beaucoup plus difficile d'y voir quoi que ce soit ». A 0.72
// il reste une lucarne au centre ou l'on devine des masses et des mouvements,
// et rien d'autre — assez pour marcher sans mur invisible, pas assez pour
// reconnaitre un camping-car.
uniform float voile : hint_range(0.0, 0.95) = 0.72;

// OU COMMENCE ET OU FINIT LA FERMETURE DU CHAMP, en rayon normalise.
//
// d vaut 0 au centre, 1.0 au milieu des bords haut et bas, 1.50 dans les coins.
// Le reglage precedent (0.50 / 1.34) gardait tout le cadre lisible et ne
// fermait vraiment que les angles.
//
// Ici la lucarne se referme AVANT le bord de l'ecran : le noir mange les deux
// tiers de l'image. C'est ce qui fait qu'on ne sait pas ou l'on est — on ne
// voit pas assez large pour reconnaitre un lieu.
uniform float ouverture : hint_range(0.1, 1.6) = 0.26;
uniform float fermeture : hint_range(0.1, 2.2) = 0.92;

// LA RESPIRATION. Ample, maintenant : le champ se resserre et s'ouvre de
// treize pour cent, lentement. Un masque qu'on porte quand on est sonne ne se
// tient pas immobile devant les yeux.
uniform float souffle : hint_range(0.0, 0.4) = 0.13;
uniform float cadence = 0.7;

// LE BATTEMENT — la part « low shutter ».
//
// L'image s'assombrit par vagues, et les vagues ne tombent pas en rythme : deux
// sinus de periodes premieres entre elles ne se resynchronisent jamais a
// l'echelle de la scene. C'est ce qui separe un clignotement d'un malaise —
// un rythme regulier s'anticipe, et on cesse de le subir au bout de dix
// secondes.
uniform float battement : hint_range(0.0, 0.6) = 0.22;

// LA TETE QUI TANGUE. Le centre du champ derive lentement, de quelques pour
// cent : on ne regarde pas droit devant soi quand on vient de se reveiller au
// fond d'un fosse.
uniform float tangage : hint_range(0.0, 0.2) = 0.035;

void fragment() {
	// L'ecran est plus large que haut ; sans correction la fermeture serait un
	// cercle et laisserait deux coins vides en haut et en bas.
	vec2 centre = vec2(
			sin(TIME * 0.37) * tangage,
			cos(TIME * 0.23) * tangage * 0.7);
	vec2 c = (UV - vec2(0.5) - centre) * vec2(1.12, 1.0);
	float d = length(c) * 2.0;

	// Inspiration lente, expiration lente.
	float r = ouverture * (1.0 - souffle * (sin(TIME * cadence) * 0.5 + 0.5));

	// Les deux vagues du battement. La seconde est plus lente et moins ample :
	// elle deplace les creux de la premiere au lieu de s'y ajouter.
	float vague = sin(TIME * 1.7) * 0.5 + 0.5;
	float lente = sin(TIME * 0.61) * 0.5 + 0.5;
	float noir = battement * (vague * 0.65 + lente * 0.35);

	float bord = smoothstep(r, fermeture, d);
	float a = mix(voile, bordure.a, bord);
	// Le battement s'ajoute AU CENTRE surtout : les bords sont deja noirs, et
	// les faire clignoter ne se verrait pas.
	a = clamp(a + noir * (1.0 - bord), 0.0, 1.0);

	// LA POSE. On integre le long du deplacement, plus un ecartement fixe qui
	// tient lieu de verre sale. Le premier echantillon est l'image nette : sans
	// lui, s'arreter donnerait une image DECALEE et non simplement floue.
	vec2 pas = (derive + normalize(c + vec2(0.0001)) * trouble) / float(PRISES);
	vec3 monde = vec3(0.0);
	for (int i = 0; i < PRISES; i++) {
		monde += texture(ecran, SCREEN_UV - pas * float(i)).rgb;
	}
	monde /= float(PRISES);

	// ON ECRIT LE MELANGE NOUS-MEMES au lieu de laisser le mixage le faire :
	// le calque doit remplacer l'image par sa version floue, pas se poser
	// par-dessus l'image nette. D'ou un alpha de 1 — le voile survit dans le
	// `mix`, pas dans la transparence.
	vec3 verre = mix(monde, teinte.rgb, a);
	COLOR = vec4(mix(verre, bordure.rgb, bord * bordure.a), 1.0);
}
