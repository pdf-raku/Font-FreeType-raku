#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
/* Get prototype. */
#include "ft_outline.h"

static int add_op(shape_t *shape, FT_OUTLINE_OP op) {
  shape->ops[ shape->n_ops++ ] = (uint8_t) op;
}

static int add_vec(shape_t *shape, const FT_Vector *v) {
  if ( shape->n_points + 2 > shape->max_points) {
    return FT_Err_Cannot_Render_Glyph;
  }
  shape->points[ shape->n_points++ ] = QEFFT2_NUM(v->x);
  shape->points[ shape->n_points++ ] = QEFFT2_NUM(v->y);
  return FT_Err_Ok;
}

static int
gather_move_to(const FT_Vector *to, void *user) {
  shape_t *shape = (shape_t *) user;
  add_op(shape, FT_OUTLINE_OP_MOVE_TO);
  return add_vec(shape, to);
}

static int
gather_line_to(const FT_Vector *to, void *user) {
  shape_t *shape = (shape_t *) user;
  add_op(shape, FT_OUTLINE_OP_LINE_TO);
  return add_vec(shape, to);
}

static int
gather_cubic_to(const FT_Vector *control1, const FT_Vector *control2,
                   const FT_Vector *to, void *user) {
  shape_t *shape = (shape_t *) user;
  add_op(shape, FT_OUTLINE_OP_CUBIC_TO);
  add_vec(shape, control1);
  add_vec(shape, control2);
  return add_vec(shape, to);
}

static int
gather_conic_to(const FT_Vector *control1, const FT_Vector *to, void *user) {
  shape_t *shape = (shape_t *) user;
  add_op(shape, FT_OUTLINE_OP_CONIC_TO);
  add_vec(shape, control1);
  return add_vec(shape, to);
}

static void _conic_to_cubic(const FT_Vector *cp1, const FT_Vector *to, FT_Vector *cp2) {
  cp2->x = cp1->x + 2.0/3.0 * (to->x - cp1->x);
  cp2->y = cp1->y + 2.0/3.0 * (to->y - cp1->y);
}

static int
gather_conic_as_cubic(const FT_Vector *control1, const FT_Vector *to, void *user) {
  FT_Vector control2;
  _conic_to_cubic(control1, to, &control2);
  return gather_cubic_to(control1, &control2, to, user);
}

DLLEXPORT FT_Error
ft_outline_gather(shape_t *shape, FT_Outline *outline, int shift, FT_Pos delta, uint8_t conic_opt) {
   FT_Outline_Funcs funcs = {
      gather_move_to,
      gather_line_to,
      (conic_opt
           ? gather_conic_to
           : gather_conic_as_cubic),
      gather_cubic_to,
      shift, delta
   };

   shape->ops = malloc(shape->max_points * sizeof( *(shape->ops) ));
   shape->points = malloc(shape->max_points * sizeof( *(shape->points) ));

   FT_Outline_Decompose(outline, &funcs, shape);
}

DLLEXPORT void
ft_outline_gather_done(shape_t *shape) {
  if (shape->ops) free(shape->ops);
  if (shape->points) free(shape->points);
  shape->ops = NULL;
  shape->points = NULL;
}
