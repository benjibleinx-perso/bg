// CE QU'ON VOIT QUAND ON PORTE LE MASQUE A GAZ.
//
// Le script dit : « Vision legerement filtree (teinte, respiration amplifiee
// dans le son) tant que le masque est porte. » Le mot qui compte est
// LEGEREMENT — c'est le premier battement jouable de la mission, et un ecran
// trop charge ferait rater les deux corps a l'arriere.
//
// Il n'y a donc que deux choses ici : une teinte froide tres faible au centre,
// et un assombrissement qui se referme sur les bords. Pas de gouttes, pas de
// rayures, pas de reflets — un masque a gaz n'a pas de hublot sale, il a un
// champ de vision reduit.
//
// ON NE LIT PAS L'ECRAN. Un hint_screen_texture permettrait de vraiment
// desaturer l'image, mais il force une copie de la cible de rendu a chaque
// image pour un resultat que personne ne distinguerait a 960x720. Le calque se
// contente de se poser PAR-DESSUS en transparence, ce qui est le budget d'une
// PS2 et le rendu qu'on cherche.
shader_type canvas_item;
render_mode blend_mix, unshaded;

// La teinte du verre. Legerement verte et desaturee : c'est du polycarbonate
// teinte, pas une lunette de vision nocturne.
//
// ELLE EST SOMBRE, ET C'EST LA CORRECTION QUI COMPTE. La premiere valeur etait
// claire (0.62, 0.70, 0.63) ; posee en transparence sur une scene de NUIT, elle
// ne teintait pas l'image, elle la lavait — le fosse devenait gris laiteux et
// perdait le noir franc qui fait toute son ambiance. Un masque assombrit,
// il n'eclaire pas. La comparaison cote a cote des deux captures est ce qui
// l'a montre ; seule, la vue masquee semblait tres bien.
uniform vec4 teinte : source_color = vec4(0.30, 0.40, 0.33, 1.0);

// Ce qu'on voit dans le coin de l'oeil, c'est-a-dire presque rien. Pas tout a
// fait opaque : un coin parfaitement noir se lit comme un cache pose sur
// l'image, alors qu'on veut un regard qui s'eteint.
uniform vec4 bordure : source_color = vec4(0.03, 0.04, 0.04, 0.9);

// Opacite de la teinte AU CENTRE.
//
// Elle a d'abord ete reglee tres bas — 0.16 — sur l'idee qu'il fallait pouvoir
// jouer. Vue en jeu, la reponse a ete « c'est pas du tout assez teinte » : a
// cette valeur, sur une scene nocturne deja sombre, on ne distingue plus si
// l'ecran est filtre ou si la nuit est simplement noire. Or c'est le tout
// premier ecran de la mission, et il doit se lire IMMEDIATEMENT comme « je
// regarde a travers quelque chose ».
//
// Le garde-fou reste le meme : il faut voir les deux corps et le decor. C'est
// une teinte franche, pas un cache.
uniform float voile : hint_range(0.0, 0.8) = 0.34;

// OU COMMENCE ET OU FINIT LA FERMETURE DU CHAMP, en rayon normalise.
//
// Ces deux nombres se lisent sur une echelle precise, et la premiere version
// s'est trompee d'echelle : d vaut 0 au centre, 1.0 au milieu des bords haut et
// bas, et 1.50 dans les coins. Regler la fermeture a 1.02 mettait donc le noir
// complet en plein dans le cadre — la capture montrait une paire de jumelles de
// dessin anime, exactement ce que le commentaire d'a cote disait d'eviter.
//
// L'ouverture doit donc rester AU-DELA de 1.0 pour que les bords restent
// lisibles, et la fermeture viser les coins. Ce qui s'assombrit alors, c'est
// uniquement le coin de l'oeil, et c'est le sens du reglage.
//
// Reglees deux fois. 0.62/1.02 mettait le noir en plein cadre — des jumelles.
// 0.98/1.55 ne fermait plus rien du tout : « ni les coins assez fermes ». Le
// bon reglage est entre les deux, et il se cherche a l'ecran, pas au calcul :
// l'ouverture reste sous 1.0 pour que le bord haut et bas s'assombrisse
// vraiment, mais le degrade est LONG — c'est sa longueur, et non sa position,
// qui separe un champ de vision reduit d'un cache decoupe.
uniform float ouverture : hint_range(0.1, 1.6) = 0.72;
uniform float fermeture : hint_range(0.1, 2.2) = 1.62;

// LA RESPIRATION, cote image. Guillaume la demande dans le SON ; on en met une
// trace ici parce qu'un filtre parfaitement fixe se lit comme un defaut
// d'affichage, alors qu'il doit se lire comme quelque chose de porte. Le champ
// se resserre de quelques pour cent, lentement. A 0.0 le filtre est fige.
uniform float souffle : hint_range(0.0, 0.2) = 0.045;
uniform float cadence = 0.85;

void fragment() {
	// L'ecran est plus large que haut ; sans correction la fermeture serait un
	// cercle et laisserait deux coins vides en haut et en bas.
	vec2 c = (UV - vec2(0.5)) * vec2(1.12, 1.0);
	float d = length(c) * 2.0;

	// Inspiration lente, expiration lente. Le sinus suffit : on ne cherche pas
	// une courbe de respiration realiste, on cherche a ne pas etre immobile.
	float r = ouverture * (1.0 - souffle * (sin(TIME * cadence) * 0.5 + 0.5));

	float bord = smoothstep(r, fermeture, d);
	float a = mix(voile, bordure.a, bord);
	COLOR = vec4(mix(teinte.rgb, bordure.rgb, bord), a);
}
